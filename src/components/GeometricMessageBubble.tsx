import React, { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Animated } from 'react-native';
import { useTheme } from '../context/ThemeEngine';

interface GeometricMessageBubbleProps {
  text: string;
  isUser: boolean;
  isFinal?: boolean;
}

export const GeometricMessageBubble: React.FC<GeometricMessageBubbleProps> = ({ text, isUser, isFinal = true }) => {
  const { theme } = useTheme();
  const { colors } = theme.styles;
  
  // Animation value for fade-in
  const fadeAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    // Only fade in for the agent
    if (!isUser) {
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 500,
        useNativeDriver: true,
      }).start();
    } else {
      // User messages show immediately
      fadeAnim.setValue(1);
    }
  }, [isUser]);

  return (
    <Animated.View style={[
      styles.container,
      isUser ? styles.userContainer : styles.agentContainer,
      { opacity: fadeAnim }
    ]}>
      <View style={[
        styles.bubble,
        { 
            backgroundColor: isUser ? colors.messageBubbleUser : colors.messageBubbleAgent,
            borderLeftColor: !isUser ? colors.primary : 'transparent',
            borderLeftWidth: !isUser ? 4 : 0,
        },
        isUser ? styles.userBubble : styles.agentBubble
      ]}>
        <Text style={[
            styles.text,
            { color: isUser ? '#fff' : '#334155' },
            !isFinal && styles.interimText
        ]}>
            {text}
        </Text>
      </View>
      <Text style={styles.timestamp}>10:42 AM</Text> 
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginVertical: 4,
    flexDirection: 'column',
  },
  userContainer: {
    alignItems: 'flex-end',
  },
  agentContainer: {
    alignItems: 'flex-start',
  },
  bubble: {
    padding: 12,
    borderRadius: 8,
    maxWidth: '85%',
  },
  userBubble: {
    borderBottomRightRadius: 2,
    borderTopLeftRadius: 12,
  },
  agentBubble: {
    borderBottomLeftRadius: 2,
    borderTopRightRadius: 12,
  },
  text: {
    fontSize: 14,
    lineHeight: 20,
  },
  interimText: {
    opacity: 0.6,
    fontStyle: 'italic',
  },
  timestamp: {
    fontSize: 10,
    color: '#9ca3af',
    marginTop: 4,
    marginHorizontal: 4,
  },
});
