import React, { useEffect } from 'react';
import { useRoomContext } from '../lkm';
import { RoomEvent, DataPacket_Kind, TranscriptionSegment, Participant } from 'livekit-client';
import { useChat, ChatMessage } from '../context/ChatContext';
import { useSessionData } from '../context/SessionDataContext';

export const ChatBridge = () => {
  const room = useRoomContext();
  const { addMessage, upsertMessage, setSendMessageHandler } = useChat();
  const { updateData, data: sessionData } = useSessionData();

  useEffect(() => {
    if (!room) return;

    // 1. Listen for incoming messages (Data Channel)
    const onDataReceived = (
      payload: Uint8Array,
      participant?: any,
      kind?: DataPacket_Kind,
      topic?: string
    ) => {
      // Decode data
      const decoder = new TextDecoder('utf-8');
      const strData = decoder.decode(payload);
      
      console.log('[ChatBridge] Data Received:', topic, strData.substring(0, 100)); // Debug log

      // If topic is 'chat', or if it's a raw JSON that looks like a message
      if (topic === 'chat') {
        const msg: ChatMessage = {
          type: 'text',
          id: Date.now().toString() + Math.random(),
          role: 'agent',
          text: strData,
          timestamp: Date.now(),
        };
        addMessage(msg);
      } else {
        try {
            const json = JSON.parse(strData);
            
            if (json.type === 'voice_interaction') {
                if (json.transcript) {
                    addMessage({
                        type: 'text',
                        id: Date.now().toString() + '_user',
                        role: 'user',
                        text: json.transcript,
                        timestamp: Date.now()
                    });
                }
                if (json.response) {
                    addMessage({
                        type: 'text',
                        id: Date.now().toString() + '_agent',
                        role: 'agent',
                        text: json.response,
                        timestamp: Date.now()
                    });
                }
            } 
            else if (json.type === 'final_structured_data' && json.data) {
                console.log('[ChatBridge] Received Structured Data:', json.data);
                updateData(json.data);
            }
            else if (json.type === 'transcription' && json.text) {
                 addMessage({
                    type: 'text',
                    id: Date.now().toString(),
                    role: 'agent',
                    text: json.text,
                    timestamp: Date.now()
                 });
            }
            // Handle Widgets (Moved from LiveSessionScreen)
            else if (json.type === 'widget' || (json.widget && json.data)) {
                 console.log('[ChatBridge] Received Widget:', json.widget);
                 addMessage({
                    type: 'widget',
                    id: Date.now().toString(),
                    role: 'agent',
                    widget: json.widget,
                    data: json.data,
                    actions: json.actions || [],
                    timestamp: Date.now(),
                    agentMessage: json.agentMessage 
                 });
            }
            // Handle UIDirectives (Standardized CADE format)
            else if (json.type === 'ui_directive' && json.directive) {
                console.log('[ChatBridge] Received UIDirective:', json.directive.widget);
                addMessage({
                    type: 'widget',
                    id: Date.now().toString(),
                    role: 'agent',
                    widget: json.directive.widget,
                    data: json.directive.data,
                    actions: json.directive.actions || [],
                    timestamp: Date.now(),
                    agentMessage: undefined // fallback_text is a summary, not a conversational message
                });
            }
            // Catch-all for generic session updates (like the Python dicts we saw)
            else if (typeof json === 'object' && !json.type && (json.status || json.session_id || json.context_summary)) {
                 console.log('[ChatBridge] Received Generic Session Data:', json);
                 updateData(json);
            }
        } catch(e) {
            console.warn('[ChatBridge] Failed to parse data:', e);
        }
      }
    };

    // 2. Listen for Standard LiveKit Transcriptions
    const onTranscriptionReceived = (
        segments: TranscriptionSegment[],
        participant?: Participant,
        publication?: any
    ) => {
        segments.forEach(seg => {
            // Check if user (local) or agent (remote)
            const role = participant?.identity === room.localParticipant.identity ? 'user' : 'agent';
            
            console.log('[ChatBridge] Transcription:', role, seg.text, seg.final ? '(FINAL)' : '(INTERIM)');
            
            upsertMessage({
                type: 'text',
                id: seg.id,
                role: role,
                text: seg.text,
                timestamp: seg.firstReceivedTime,
                isFinal: seg.final,
            });
        });
    };

    room.on(RoomEvent.DataReceived, onDataReceived);
    room.on(RoomEvent.TranscriptionReceived, onTranscriptionReceived);

    // 3. Setup outgoing handler (LiveKit Data Channel)
    const sendHandler = async (text: string) => {
      console.log('[ChatBridge] Attempting to send message:', text);
      
      if (!room) {
        console.error('[ChatBridge] Room is undefined, cannot send message.');
        return;
      }

      if (!room.localParticipant) {
        console.error('[ChatBridge] LocalParticipant is undefined, cannot send message.');
        return;
      }
      
      try {
        // Use sendText with topic 'lk.chat' as expected by the backend agent
        console.log('[ChatBridge] Sending text to topic: lk.chat');
        // @ts-ignore - sendText might not be in the type definition yet if types are old, but it exists in runtime
        await room.localParticipant.sendText(text, { topic: 'lk.chat' });
        console.log('[ChatBridge] Sent text via Socket:', text);
      } catch (e) {
        console.error('[ChatBridge] Failed to send via Socket:', e);
        
        // Fallback to publishData if sendText fails (e.g. older SDK)
        try {
            const encoder = new TextEncoder();
            const data = encoder.encode(text);
            await room.localParticipant.publishData(data, { reliable: true, topic: 'lk.chat' });
            console.log('[ChatBridge] Fallback: Sent text via publishData to lk.chat');
        } catch (fallbackError) {
            console.error('[ChatBridge] Fallback failed:', fallbackError);
        }
      }
    };

    setSendMessageHandler(sendHandler);

    return () => {
      room.off(RoomEvent.DataReceived, onDataReceived);
      room.off(RoomEvent.TranscriptionReceived, onTranscriptionReceived);
    };
  }, [room, addMessage, setSendMessageHandler, updateData, sessionData]);

  return null;
};
