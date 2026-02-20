import React, { useEffect, useRef } from 'react';
import { View, Text, StyleSheet, Animated } from 'react-native';
import { useTheme } from '../context/ThemeEngine';
import { Ionicons } from '@expo/vector-icons';

interface MessageBubbleProps {
  text: string;
  isUser: boolean;
  isFinal?: boolean;
}

export const MessageBubble: React.FC<MessageBubbleProps> = ({ text, isUser, isFinal = true }) => {
  const { theme } = useTheme();
  const { colors } = theme.styles;
  const fadeAnim = useRef(new Animated.Value(isUser ? 1 : 0)).current;

  useEffect(() => {
    if (!isUser) {
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 300,
        useNativeDriver: true,
      }).start();
    }
  }, [isUser]);

  return (
    <Animated.View style={[
      styles.container,
      isUser ? styles.userContainer : styles.agentContainer,
      { opacity: fadeAnim }
    ]}>
      {!isUser && (
        <View style={[styles.avatarContainer, { backgroundColor: colors.cardBackground }]}>
           <Ionicons name="sparkles" size={16} color={colors.primary} />
        </View>
      )}

      <View style={[
        styles.bubble,
        {
          backgroundColor: isUser ? colors.messageBubbleUser : colors.messageBubbleAgent,
          borderBottomRightRadius: isUser ? 2 : 12,
          borderBottomLeftRadius: isUser ? 12 : 2,
          borderLeftWidth: !isUser ? 4 : 0,
          borderLeftColor: !isUser ? colors.primary : 'transparent',
        }
      ]}>
        <Text style={[
            styles.text,
            { color: isUser ? '#fff' : colors.text },
            !isFinal && styles.interimText
        ]}>
            {text}
        </Text>
      </View>

      {isUser && (
        <View style={[styles.avatarContainer, { backgroundColor: colors.messageBubbleUser, marginLeft: 8 }]}>
             <Ionicons name="person" size={16} color="#FFF" />
        </View>
      )}
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    marginBottom: 16,
    width: '100%',
    paddingHorizontal: 0,
  },
  userContainer: {
    justifyContent: 'flex-end',
  },
  agentContainer: {
    justifyContent: 'flex-start',
  },
  avatarContainer: {
    width: 32,
    height: 32,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 8,
  },
  bubble: {
    paddingHorizontal: 16,
    paddingVertical: 12,
    borderRadius: 12,
    maxWidth: '75%',
    shadowColor: "#000",
    shadowOffset: {
      width: 0,
      height: 1,
    },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 1,
  },
  text: {
    fontSize: 15,
    lineHeight: 22,
  },
  interimText: {
    opacity: 0.7,
    fontStyle: 'italic',
  },
});
