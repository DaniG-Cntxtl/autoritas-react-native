import React, { useEffect } from 'react';
import { useRoomContext } from '../lkm';
import { RoomEvent } from 'livekit-client';
import { useTheme, GeneratedTheme } from '../context/ThemeEngine';

export const ThemeHandler = () => {
  const room = useRoomContext();
  const { applyTheme } = useTheme();

  useEffect(() => {
    if (!room) return;

    const onDataReceived = (
      payload: Uint8Array,
      participant?: any,
      kind?: any,
      topic?: string
    ) => {
      // We only care about theme updates here
      if (topic !== 'ui_theme_update') return;

      try {
        const decoder = new TextDecoder('utf-8');
        const strData = decoder.decode(payload);
        const themePayload: GeneratedTheme = JSON.parse(strData);
        
        console.log('[LiveKit] Applying New Theme:', themePayload.meta?.name);
        applyTheme(themePayload);
      } catch (error) {
        console.error('[LiveKit] Failed to parse theme payload:', error);
      }
    };

    room.on(RoomEvent.DataReceived, onDataReceived);

    return () => {
      room.off(RoomEvent.DataReceived, onDataReceived);
    };
  }, [room, applyTheme]);

  return null; // This component is logic-only
};
