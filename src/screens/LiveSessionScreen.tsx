import React, { useEffect, useState } from 'react';
import { View, StyleSheet, Text, TouchableOpacity, StatusBar } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useRoomContext } from '../lkm';
import { RoomEvent, DataPacket_Kind } from 'livekit-client';
import { Ionicons, MaterialIcons } from '@expo/vector-icons';
import { ThemeHandler } from '../components/ThemeHandler';
import { ChatBridge } from '../components/ChatBridge';
import { ChatInterface } from '../components/ChatInterface';
import { VoiceVisualizer } from '../components/VoiceVisualizer';
import { CrossPlatformBlur } from '../components/CrossPlatformBlur';
import { useChat } from '../context/ChatContext';
import { useTheme } from '../context/ThemeEngine';
import { STITCH_THEME, STITCH_THEME_DARK } from '../themes/StitchTheme';
import { LinearGradient } from 'expo-linear-gradient';

// Types
type ViewMode = 'voice' | 'chat';

const LiveSessionScreen = ({ onExit }: { onExit: () => void }) => {
  const room = useRoomContext();
  const { addMessage } = useChat();
  const { applyTheme, theme } = useTheme();
  
  const [viewMode, setViewMode] = useState<ViewMode>('chat');
  const [isMuted, setIsMuted] = useState(false);

  // Apply Stitch Theme on mount
  useEffect(() => {
    // Default to light if not already set to a stitch theme
    if (theme.meta.name === 'Default System') {
      applyTheme(STITCH_THEME);
    }
  }, []);

  const toggleTheme = () => {
    if (theme.meta.name.includes('Dark')) {
      applyTheme(STITCH_THEME);
    } else {
      applyTheme(STITCH_THEME_DARK);
    }
  };

  const toggleMute = () => {
    if (room?.localParticipant) {
      const isEnabled = room.localParticipant.isMicrophoneEnabled;
      room.localParticipant.setMicrophoneEnabled(!isEnabled);
      setIsMuted(!isEnabled);
    }
  };

  const renderHeader = () => {
    const isDark = theme.meta.name.includes('Dark');
    return (
      <View style={[styles.header, { backgroundColor: isDark ? 'rgba(16, 25, 34, 0.9)' : 'rgba(255, 255, 255, 0.9)', borderBottomColor: theme.styles.colors.accent }]}>
        <TouchableOpacity style={[styles.lightIconButton, { backgroundColor: theme.styles.colors.accent }]} onPress={onExit}>
          <MaterialIcons name="arrow-back" size={22} color={theme.styles.colors.text} />
        </TouchableOpacity>
        
        <View style={{ alignItems: 'center' }}>
          <Text style={[styles.lightHeaderTitle, { color: theme.styles.colors.text }]}>Support</Text>
          <View style={{ flexDirection: 'row', alignItems: 'center', marginTop: 2 }}>
            <View style={[styles.activeDot, { width: 6, height: 6 }]} />
            <Text style={styles.lightSubStatusText}>LIVE CALL</Text>
          </View>
        </View>

        <TouchableOpacity style={[styles.lightIconButton, { backgroundColor: theme.styles.colors.accent }]} onPress={toggleTheme}>
          <MaterialIcons name={isDark ? "light-mode" : "dark-mode"} size={22} color={theme.styles.colors.text} />
        </TouchableOpacity>
      </View>
    );
  };

  const renderFooter = () => {
    if (viewMode === 'voice') {
      const isDark = theme.meta.name.includes('Dark');
      return (
        <View style={[styles.footer, { backgroundColor: isDark ? 'rgba(16, 25, 34, 0.95)' : 'rgba(248, 249, 250, 0.95)', borderTopColor: theme.styles.colors.accent }]}>
          <TouchableOpacity 
            style={[styles.lightCircleButton, { backgroundColor: theme.styles.colors.cardBackground, borderColor: theme.styles.colors.accent }]}
            onPress={() => setViewMode('chat')}
          >
            <MaterialIcons name="keyboard" size={24} color={theme.styles.colors.text} />
          </TouchableOpacity>

          <TouchableOpacity 
            style={styles.endCallButton} 
            onPress={onExit}
          >
            <MaterialIcons name="call-end" size={24} color="#fff" />
            <Text style={styles.endCallText}>End Call</Text>
          </TouchableOpacity>

          <TouchableOpacity 
            style={[styles.lightCircleButton, { backgroundColor: theme.styles.colors.cardBackground, borderColor: theme.styles.colors.accent }]}
            onPress={toggleMute}
          >
            <MaterialIcons name={isMuted ? "mic-off" : "mic"} size={24} color={isMuted ? "#ef4444" : theme.styles.colors.text} />
          </TouchableOpacity>
        </View>
      );
    }
    return null; // Chat mode has its own input bar
  };

  return (
    <View style={[styles.container, { backgroundColor: theme.styles.colors.background }]}>
      <StatusBar barStyle={theme.meta.name.includes('Dark') ? "light-content" : "dark-content"} />
      <ThemeHandler />
      <ChatBridge />

      <SafeAreaView style={styles.safeArea} edges={['top', 'left', 'right']}>
        {renderHeader()}

        <View style={styles.content}>
          {viewMode === 'voice' ? (
            <View style={styles.voiceContainer}>
              <VoiceVisualizer isActive={!isMuted} />
            </View>
          ) : (
            <View style={styles.chatContainer}>
              <ChatInterface />
            </View>
          )}
        </View>

        {renderFooter()}
      </SafeAreaView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  safeArea: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingTop: 10,
    paddingBottom: 10,
    zIndex: 10,
    borderBottomWidth: 1,
  },
  lightIconButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  lightHeaderTitle: {
    fontSize: 14,
    fontWeight: '700',
    letterSpacing: 0.5,
  },
  lightSubStatusText: {
    color: '#16a34a',
    fontSize: 10,
    fontWeight: '600',
    letterSpacing: 1,
    marginLeft: 4,
  },
  activeDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#22c55e',
  },
  content: {
    flex: 1,
  },
  voiceContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  chatContainer: {
    flex: 1,
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 24,
    paddingBottom: 20,
    paddingTop: 20,
    borderTopWidth: 1,
  },
  lightCircleButton: {
    width: 56,
    height: 56,
    borderRadius: 28,
    borderWidth: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  endCallButton: {
    height: 56,
    flex: 1,
    marginHorizontal: 16,
    borderRadius: 28,
    backgroundColor: '#dc2626',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    shadowColor: '#fca5a5',
    shadowOpacity: 0.5,
    shadowRadius: 10,
    shadowOffset: { width: 0, height: 4 },
  },
  endCallText: {
    color: '#fff',
    fontWeight: '700',
    fontSize: 14,
    textTransform: 'uppercase',
    letterSpacing: 1,
  },
});

export default LiveSessionScreen;
