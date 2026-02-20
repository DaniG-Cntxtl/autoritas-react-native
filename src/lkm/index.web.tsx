import React, { createContext, useContext, useEffect, useState } from 'react';
import { Room, RoomEvent, RemoteTrack, Track } from 'livekit-client';

// Mock Globals
export const registerGlobals = () => {};
export const AudioSession = {
  startAudioSession: () => {},
  stopAudioSession: () => {},
};

// Context
const RoomContext = createContext<Room | undefined>(undefined);

export const useRoomContext = () => {
  return useContext(RoomContext);
};

// Internal Audio Renderer for Web
const AudioRenderer = ({ room }: { room: Room }) => {
  useEffect(() => {
    const handleTrackSubscribed = (track: RemoteTrack) => {
      if (track.kind === Track.Kind.Audio) {
        console.log('[LiveKit-Web] Audio Track Subscribed:', track.sid);
        const element = track.attach();
        document.body.appendChild(element);
      }
    };

    const handleTrackUnsubscribed = (track: RemoteTrack) => {
      if (track.kind === Track.Kind.Audio) {
        track.detach().forEach(el => el.remove());
      }
    };

    room.on(RoomEvent.TrackSubscribed, handleTrackSubscribed);
    room.on(RoomEvent.TrackUnsubscribed, handleTrackUnsubscribed);

    // Attach existing tracks
    room.remoteParticipants.forEach(p => {
      p.trackPublications.forEach(pub => {
        if (pub.isSubscribed && pub.track && pub.track.kind === Track.Kind.Audio) {
          handleTrackSubscribed(pub.track as RemoteTrack);
        }
      });
    });

    return () => {
      room.off(RoomEvent.TrackSubscribed, handleTrackSubscribed);
      room.off(RoomEvent.TrackUnsubscribed, handleTrackUnsubscribed);
    };
  }, [room]);

  return null;
};

// Web Compatible LiveKitRoom
export const LiveKitRoom = ({
  token,
  serverUrl,
  connect,
  options,
  children,
  style,
  ...props
}: any) => {
  const [room, setRoom] = useState<Room | undefined>(undefined);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!connect || !token || !serverUrl) return;

    // Determine protocol: if we are on https OR it is a cloud instance, force wss
    let finalUrl = serverUrl;
    const isCloud = finalUrl.includes('.livekit.cloud');
    const isSecureContext = window.location.protocol === 'https:';
    
    if ((isSecureContext || isCloud) && finalUrl.startsWith('ws://') && !finalUrl.includes('localhost') && !finalUrl.includes('127.0.0.1')) {
      finalUrl = finalUrl.replace('ws://', 'wss://');
      console.log('[LiveKit-Web] Upgrading to wss for Cloud/Secure context:', finalUrl);
    }

    const r = new Room(options);
    r.connect(finalUrl, token)
      .then(async () => {
        console.log('[LiveKit-Web] Connected to room:', r.name);
        setRoom(r);
        // Auto-publish microphone
        try {
          await r.localParticipant.setMicrophoneEnabled(true);
          console.log('[LiveKit-Web] Microphone published');
        } catch (e) {
          console.error('[LiveKit-Web] Failed to publish microphone:', e);
        }
      })
      .catch((err) => {
        console.error('[LiveKit-Web] Failed to connect:', err);
        setError(err.message || 'Failed to connect');
      });

    return () => {
      r.disconnect();
    };
  }, [connect, token, serverUrl]);

  // Loading / Error State Styles
  const containerStyle = {
    flex: 1,
    display: 'flex',
    flexDirection: 'column',
    height: '100%',
    backgroundColor: '#000', // Ensure dark background
    color: '#fff',
    fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif',
    ...style
  };

  if (error) {
     return (
      <div style={{ ...containerStyle, alignItems: 'center', justifyContent: 'center' }}>
        <div style={{ color: '#ff453a', fontSize: 16, marginBottom: 10 }}>Connection Error</div>
        <div style={{ color: '#8e8e93', fontSize: 14 }}>{error}</div>
      </div>
    );
  }

  return (
    <RoomContext.Provider value={room}>
      <div style={containerStyle} {...props}>
        {room ? (
          <>
            <AudioRenderer room={room} />
            {children}
          </>
        ) : (
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
            {/* Simple CSS Spinner or Text */}
            <div style={{ marginBottom: 15, fontSize: 16, fontWeight: 500 }}>Connecting to Live Session...</div>
            <div style={{ color: '#8e8e93' }}>Establishing secure connection</div>
          </div>
        )}
      </div>
    </RoomContext.Provider>
  );
};