import React, { useState, useCallback, useRef } from 'react';
import { View, Text, TextInput, StyleSheet, KeyboardAvoidingView, Platform, Pressable } from 'react-native';
import { FlashList } from '@shopify/flash-list';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '../context/ThemeEngine';
import { useChat } from '../context/ChatContext';
import { ActionButtons } from './widgets/ActionButtons';
import { DeviceGrid } from './widgets/DeviceGrid';
import { PlanCard } from './widgets/PlanCard';
import { PlanGrid } from './widgets/PlanGrid';
import { InvoiceSummary } from './widgets/InvoiceSummary';
import { RouterDiagnostics } from './widgets/RouterDiagnostics';
import { DocumentPreview } from './widgets/DocumentPreview';
import { TelemetryDashboard } from './widgets/TelemetryDashboard';
import { WelcomeMenu } from './widgets/WelcomeMenu';
import { MessageBubble } from './MessageBubble';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

export const ChatInterface = () => {
  const { theme } = useTheme();
  const { messages, sendMessage, updateMessage } = useChat();
  const { colors, layout, typography } = theme.styles;
  const [inputText, setInputText] = useState('');
  const insets = useSafeAreaInsets();
  const listRef = useRef<any>(null);

  const handleSend = useCallback(() => {
    console.log('[ChatInterface] handleSend triggered', inputText);
    if (!inputText.trim()) {
        console.log('[ChatInterface] Input empty, ignoring');
        return;
    }
    const textToSend = inputText;
    // Clear immediately for better UX
    setInputText('');
    
    // Send message
    console.log('[ChatInterface] Calling sendMessage with:', textToSend);
    sendMessage(textToSend);
  }, [inputText, sendMessage]);

  const handleWidgetAction = useCallback((messageId: string, actionId: string, payload?: any) => {
    console.log('Widget Action:', messageId, actionId, payload);
    updateMessage(messageId, { selectedActionId: actionId });
    sendMessage(actionId);
  }, [updateMessage, sendMessage]);

  const renderItem = useCallback(({ item: msg }: { item: any }) => {
    if (msg.type === 'text') {
      return (
        <MessageBubble 
          text={msg.text} 
          isUser={msg.role === 'user'} 
          isFinal={msg.isFinal}
        />
      );
    } else if (msg.type === 'widget') {
      return (
        <View style={styles.widgetContainer}>
          {msg.widget === 'action_buttons' && (
            <ActionButtons
              data={msg.data}
              actions={msg.actions}
              selectedActionId={msg.selectedActionId}
              agentMessage={msg.agentMessage}
              onAction={(actionId) => handleWidgetAction(msg.id, actionId)}
            />
          )}
          {msg.widget === 'device_grid' && (
            <DeviceGrid
              data={msg.data}
              actions={msg.actions}
              selectedActionId={msg.selectedActionId}
              agentMessage={msg.agentMessage}
              onAction={(actionId, device) => handleWidgetAction(msg.id, actionId, device)}
            />
          )}
          {msg.widget === 'plan_card' && (
            <PlanCard
              data={msg.data}
              actions={msg.actions}
              agentMessage={msg.agentMessage}
              onAction={(actionId) => handleWidgetAction(msg.id, actionId)}
            />
          )}
          {msg.widget === 'plan_grid' && (
            <PlanGrid
              data={msg.data}
              actions={msg.actions}
              selectedActionId={msg.selectedActionId}
              agentMessage={msg.agentMessage}
              onAction={(actionId, plan) => handleWidgetAction(msg.id, actionId, plan)}
            />
          )}
          {msg.widget === 'invoice_summary' && (
            <InvoiceSummary
              data={msg.data}
              actions={msg.actions}
              agentMessage={msg.agentMessage}
              onAction={(actionId) => handleWidgetAction(msg.id, actionId)}
            />
          )}
          {msg.widget === 'router_diagnostics' && (
            <RouterDiagnostics
              data={msg.data}
              actions={msg.actions}
              agentMessage={msg.agentMessage}
              onAction={(actionId) => handleWidgetAction(msg.id, actionId)}
            />
          )}
          {msg.widget === 'document_preview' && (
            <DocumentPreview
              data={msg.data}
              actions={msg.actions}
              agentMessage={msg.agentMessage}
              onAction={(actionId) => handleWidgetAction(msg.id, actionId)}
            />
          )}
          {msg.widget === 'telemetry_dashboard' && (
            <TelemetryDashboard
              data={msg.data}
              actions={msg.actions}
              agentMessage={msg.agentMessage}
              onAction={(actionId) => handleWidgetAction(msg.id, actionId)}
            />
          )}
          {msg.widget === 'welcome_menu' && (
            <WelcomeMenu
              data={msg.data}
              onAction={(actionId) => handleWidgetAction(msg.id, actionId)}
            />
          )}
        </View>
      );
    }
    return null;
  }, [handleWidgetAction]);

  const keyExtractor = useCallback((item: any) => item.id, []);

  return (
    <KeyboardAvoidingView 
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      style={styles.container}
      keyboardVerticalOffset={Platform.OS === 'ios' ? 0 : 0}
    >
      <View style={[styles.gradient, { backgroundColor: theme.styles.colors.background }]}>
        <View style={[styles.header, { backgroundColor: 'transparent', borderBottomWidth: 1, borderBottomColor: theme.styles.colors.accent }]}>
           <View style={styles.statusDot} />
           <Text style={[styles.statusText, { color: theme.styles.colors.secondaryText }]}>VOICE ACTIVE • LISTENING</Text>
        </View>

        <View style={styles.scrollContainer}>
            {messages.length === 0 ? (
            <View style={styles.emptyState}>
                <Ionicons name="chatbubble-ellipses-outline" size={48} color={theme.styles.colors.secondaryText} style={{ opacity: 0.5 }} />
                <Text style={[styles.emptyText, { color: theme.styles.colors.secondaryText }]}>Start a conversation...</Text>
            </View>
            ) : (
            <FlashList
                ref={listRef}
                data={messages}
                renderItem={renderItem}
                keyExtractor={keyExtractor}
                // @ts-ignore
                estimatedItemSize={100}
                contentContainerStyle={styles.messagesContent}
                showsVerticalScrollIndicator={false}
                keyboardDismissMode="on-drag"
                onContentSizeChange={() => {
                  if (messages.length > 0) {
                    listRef.current?.scrollToEnd({ animated: true });
                  }
                }}
                onLayout={() => {
                  if (messages.length > 0) {
                    listRef.current?.scrollToEnd({ animated: true });
                  }
                }}
            />
            )}
        </View>
        
        <View style={[
            styles.inputContainer, 
            { 
              backgroundColor: theme.styles.colors.cardBackground,
              borderTopColor: theme.styles.colors.accent,
              paddingBottom: Platform.OS === 'ios' ? Math.max(insets.bottom, 20) : 20
            }
        ]}>
            <View style={[styles.textInputWrapper, { backgroundColor: theme.styles.colors.inputBackground, borderColor: theme.styles.colors.accent }]}>
                <TextInput 
                    style={[styles.textInput, { color: theme.styles.colors.text }]}
                    placeholder="Type a message..."
                    placeholderTextColor={theme.styles.colors.secondaryText}
                    value={inputText}
                    onChangeText={setInputText}
                    onSubmitEditing={handleSend}
                    returnKeyType="send"
                    enablesReturnKeyAutomatically
                />
            </View>
            <Pressable 
                onPress={handleSend}
                disabled={!inputText.trim()}
                style={({ pressed }) => [
                    styles.sendButton,
                    { backgroundColor: theme.styles.colors.primary },
                    { opacity: !inputText.trim() ? 0.5 : (pressed ? 0.8 : 1) },
                    { transform: [{ scale: pressed ? 0.95 : 1 }] }
                ]}
            >
            <Ionicons name="arrow-up" size={20} color="#FFF" />
            </Pressable>
        </View>
      </View>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  gradient: {
    flex: 1,
  },
  header: {
    paddingTop: 10,
    paddingBottom: 10,
    paddingHorizontal: 20,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  scrollContainer: {
    flex: 1, 
    paddingHorizontal: 0
  },
  messagesContent: {
    paddingHorizontal: 16,
    paddingBottom: 20,
    paddingTop: 20,
  },
  emptyState: { 
    flex: 1, 
    justifyContent: 'center', 
    alignItems: 'center', 
  },
  emptyText: {
    fontSize: 16,
    marginTop: 10,
  },
  statusDot: { 
    width: 6, 
    height: 6, 
    borderRadius: 3, 
    backgroundColor: '#30d158', 
    marginRight: 8,
  },
  statusText: { 
    fontSize: 11, 
    fontWeight: '700',
    letterSpacing: 1,
  },
  inputContainer: {
    flexDirection: 'row',
    paddingHorizontal: 16,
    paddingTop: 12,
    alignItems: 'center',
    borderTopWidth: 1,
  },
  textInputWrapper: {
    flex: 1,
    borderRadius: 24,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    height: 48,
    marginRight: 12,
    borderWidth: 1,
  },
  textInput: {
    flex: 1,
    fontSize: 16,
    height: '100%',
  },
  sendButton: {
    width: 44,
    height: 44,
    borderRadius: 22,
    justifyContent: 'center',
    alignItems: 'center',
  },
  widgetContainer: {
    width: '100%',
    marginBottom: 16,
  }
});
