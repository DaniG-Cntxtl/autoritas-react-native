import React, { createContext, useContext, useState, useCallback } from 'react';

export interface TextMessage {
  type: 'text';
  id: string;
  role: 'user' | 'agent';
  text: string;
  timestamp: number;
  isFinal?: boolean; // Added to track interim vs final transcription
}

export interface WidgetMessage {
  type: 'widget';
  id: string;
  role: 'agent';
  widget: string;
  data: any;
  actions: any[];
  selectedActionId?: string | null;
  agentMessage?: string | null;
  timestamp: number;
}

export type ChatMessage = TextMessage | WidgetMessage;

interface ChatContextType {
  messages: ChatMessage[];
  addMessage: (msg: ChatMessage) => void;
  updateMessage: (id: string, updates: Partial<ChatMessage>) => void;
  upsertMessage: (msg: ChatMessage) => void;
  sendMessage: (text: string) => void; 
  setSendMessageHandler: (handler: (text: string) => void) => void;
}

const ChatContext = createContext<ChatContextType>({
  messages: [],
  addMessage: () => {},
  updateMessage: () => {},
  upsertMessage: () => {},
  sendMessage: () => {},
  setSendMessageHandler: () => {},
});

export const useChat = () => useContext(ChatContext);

export const ChatProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  
  const [sendHandler, setSendHandler] = useState<((text: string) => void) | null>(null);

  const addMessage = useCallback((msg: ChatMessage) => {
    setMessages(prev => [...prev, msg]);
  }, []);

  const updateMessage = useCallback((id: string, updates: Partial<ChatMessage>) => {
    setMessages(prev => prev.map(msg => msg.id === id ? { ...msg, ...updates } as ChatMessage : msg));
  }, []);

  const upsertMessage = useCallback((msg: ChatMessage) => {
    setMessages(prev => {
      const index = prev.findIndex(m => m.id === msg.id);
      if (index !== -1) {
        // Update existing
        const newMessages = [...prev];
        newMessages[index] = { ...newMessages[index], ...msg };
        return newMessages;
      } else {
        // Add new
        return [...prev, msg];
      }
    });
  }, []);

  const setSendMessageHandler = useCallback((handler: (text: string) => void) => {
    setSendHandler(() => handler);
  }, []);

  const sendMessage = useCallback((text: string) => {
    // 1. Add locally immediately
    console.log('[ChatContext] Adding local message:', text);
    addMessage({ 
      type: 'text',
      id: Date.now().toString(), 
      role: 'user', 
      text, 
      timestamp: Date.now() 
    });
    
    // 2. Delegate to LiveKit
    if (sendHandler) {
      console.log('[ChatContext] Calling sendHandler');
      sendHandler(text);
    } else {
      console.warn("No Send Handler registered (LiveKit not connected?)");
    }
  }, [addMessage, sendHandler]);

  return (
    <ChatContext.Provider value={{ messages, addMessage, updateMessage, upsertMessage, sendMessage, setSendMessageHandler }}>
      {children}
    </ChatContext.Provider>
  );
};
