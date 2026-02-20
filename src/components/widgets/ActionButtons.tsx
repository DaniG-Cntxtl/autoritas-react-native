import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { useTheme } from '../../context/ThemeEngine';

export interface UIAction {
  id: string;
  label: string;
  style: 'primary' | 'secondary' | 'success' | 'danger' | 'link';
  icon?: string;
  disabled?: boolean;
}

interface ActionButtonsProps {
  data?: {
    title?: string;
    description?: string;
  };
  actions: UIAction[];
  selectedActionId?: string | null;
  agentMessage?: string | null;
  onAction: (actionId: string) => void;
}

export const ActionButtons: React.FC<ActionButtonsProps> = ({
  data,
  actions,
  selectedActionId,
  agentMessage,
  onAction,
}) => {
  const { theme } = useTheme();
  const { colors } = theme.styles;
  const hasSelection = selectedActionId !== null && selectedActionId !== undefined;

  const getButtonStyle = (action: UIAction) => {
    const isSelected = selectedActionId === action.id;
    const isDisabledBySelection = hasSelection && !isSelected;

    if (isDisabledBySelection) {
      return { opacity: 0.4, transform: [{ scale: 0.95 }] };
    }
    
    if (isSelected) {
        return { transform: [{ scale: 1.02 }] };
    }

    return {};
  };

  const getGradientColors = (style: string, isSelected: boolean): readonly [string, string, ...string[]] => {
    if (isSelected) return ['#10b981', '#059669']; // Success green for selected
    
    switch (style) {
      case 'primary':
        return [colors.primary, colors.primary + 'CC']; // Use primary from theme
      case 'success':
        return ['#10b981', '#059669'];
      case 'danger':
        return ['#ef4444', '#dc2626'];
      default:
        return [colors.accent, colors.accent]; // Use accent from theme for secondary
    }
  };

  return (
    <View style={[
        styles.container, 
        { backgroundColor: colors.cardBackground, borderColor: colors.accent },
        hasSelection && { borderColor: '#10b981' }
    ]}>
      {data?.title && (
        <View style={styles.header}>
          <Text style={[styles.title, { color: colors.text }]}>{data.title}</Text>
          {data.description && <Text style={[styles.description, { color: colors.secondaryText }]}>{data.description}</Text>}
        </View>
      )}

      <View style={styles.buttonsContainer}>
        {actions.map((action) => {
          const isSelected = selectedActionId === action.id;
          const gradientColors = getGradientColors(action.style, isSelected);
          const isSecondary = action.style === 'secondary' && !isSelected;
          
          return (
            <TouchableOpacity
              key={action.id}
              onPress={() => !hasSelection && !action.disabled && onAction(action.id)}
              disabled={action.disabled || (hasSelection && !isSelected)}
              style={[styles.buttonWrapper, getButtonStyle(action)]}
            >
              <LinearGradient
                colors={gradientColors}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 1 }}
                style={[
                    styles.button,
                    isSecondary && { borderWidth: 1, borderColor: colors.accent }
                ]}
              >
                {isSelected ? (
                   <Text style={styles.icon}>✓</Text>
                ) : action.icon ? (
                   <Text style={[styles.icon, isSecondary && { color: colors.secondaryText }]}>{action.icon}</Text>
                ) : null}
                <Text style={[styles.buttonText, isSecondary && { color: colors.text }]}>{action.label}</Text>
              </LinearGradient>
            </TouchableOpacity>
          );
        })}
      </View>

      {agentMessage && (
        <View style={[styles.agentMessage, { backgroundColor: colors.inputBackground, borderLeftColor: colors.primary }]}>
          <Text style={[styles.agentMessageText, { color: colors.text }]}>{agentMessage}</Text>
        </View>
      )}

      {hasSelection && (
        <Text style={styles.selectionFeedback}>Seleccionado ✓</Text>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    padding: 16,
    borderRadius: 16,
    borderWidth: 1,
    marginVertical: 8,
    width: '100%',
    shadowColor: '#000',
    shadowOpacity: 0.05,
    shadowRadius: 4,
    shadowOffset: { width: 0, height: 2 },
  },
  header: {
    marginBottom: 16,
    alignItems: 'center',
  },
  title: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 8,
  },
  description: {
    fontSize: 14,
    textAlign: 'center',
  },
  buttonsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
    justifyContent: 'center',
  },
  buttonWrapper: {
    borderRadius: 12,
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOpacity: 0.1,
    shadowRadius: 2,
    shadowOffset: { width: 0, height: 1 },
  },
  button: {
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 12,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  buttonText: {
    color: '#fff',
    fontWeight: '600',
    fontSize: 15,
  },
  icon: {
    color: '#fff',
    fontSize: 16,
    marginRight: 4,
  },
  agentMessage: {
    marginTop: 16,
    padding: 14,
    borderRadius: 12,
    borderLeftWidth: 3,
  },
  agentMessageText: {
    fontSize: 14,
    lineHeight: 20,
  },
  selectionFeedback: {
    marginTop: 12,
    textAlign: 'center',
    color: '#10b981',
    fontWeight: '500',
    fontSize: 14,
  },
});