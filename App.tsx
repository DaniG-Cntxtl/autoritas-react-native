import React, { useState } from 'react';
import { StyleSheet, View } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import { LiveKitRoom } from './src/lkm';
import { AudioSession } from './src/lkm';

import { ThemeEngineProvider, useTheme } from './src/context/ThemeEngine';
import { fetchLiveKitToken } from './src/services/AuthService';
import { ChatProvider } from './src/context/ChatContext';
import { SessionDataProvider } from './src/context/SessionDataContext';
import LiveSessionScreen from './src/screens/LiveSessionScreen';
import { LoginScreen } from './src/screens/LoginScreen';

// Polyfill WebRTC
import { registerGlobals } from './src/lkm';
registerGlobals();

// Start Audio Session on app launch
AudioSession.startAudioSession();

const AppContent = () => {
  const { theme } = useTheme();
  const [currentScreen, setCurrentScreen] = useState<'login' | 'chat'>('login');
  
  // LiveKit State
  const [lkToken, setLkToken] = useState('');
  const [lkUrl, setLkUrl] = useState('https://agent.autoritas.ai');

  // --- Auth & Navigation ---
  const handleLoginSuccess = async () => {
    try {
      // For POC, simulate fetching token immediately after login
      // In real app, might go to Home first, then join room
      const randomUser = `user-${Math.floor(Math.random() * 1000)}`;
      
      // Using 'test-room' for now, or could come from user selection
      const { token, url } = await fetchLiveKitToken('test-room', randomUser);
      
      console.log('[App] Received Auth:', { url, token: token.substring(0, 10) + '...' });
      
      setLkToken(token);
      setLkUrl(url);
      setCurrentScreen('chat');
    } catch (e) {
      console.error(e);
      alert('Could not fetch LiveKit token. Check connection.');
    }
  };

  const handleExit = () => {
    setLkToken('');
    setCurrentScreen('login');
  };

  if (currentScreen === 'chat' && lkToken) {
    return (
      <LiveKitRoom
        token={lkToken}
        serverUrl={lkUrl}
        connect={true}
        options={{
          adaptiveStream: true,
          dynacast: true,
        }}
        data-lk-theme="default"
      >
         <LiveSessionScreen onExit={handleExit} />
      </LiveKitRoom>
    );
  }

  return (
    <View style={styles.container}>
        <StatusBar style="light" />
        <LoginScreen onLoginSuccess={handleLoginSuccess} />
    </View>
  );
};

export default function App() {
  return (
    <SafeAreaProvider>
      <ThemeEngineProvider>
        <SessionDataProvider>
          <ChatProvider>
            <AppContent />
          </ChatProvider>
        </SessionDataProvider>
      </ThemeEngineProvider>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#000' },
});
