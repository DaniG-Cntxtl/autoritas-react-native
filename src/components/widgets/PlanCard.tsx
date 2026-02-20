import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { useTheme } from '../../context/ThemeEngine';

interface UIAction {
  id: string;
  label: string;
  style: 'primary' | 'secondary' | 'success' | 'danger' | 'link';
  icon?: string;
  disabled?: boolean;
}

interface PlanData {
  name: string;
  price: number;
  period?: string;
  features: string[];
  data_gb?: number;
  calls_minutes?: number | string;
  sms?: number | string;
  badge?: string;
  highlighted?: boolean;
}

interface PlanCardProps {
  data: PlanData;
  actions: UIAction[];
  agentMessage?: string | null;
  onAction: (actionId: string) => void;
}

export const PlanCard: React.FC<PlanCardProps> = ({ data, actions, agentMessage, onAction }) => {
  const { theme } = useTheme();
  const { colors } = theme.styles;

  return (
    <View
      style={[styles.container, { backgroundColor: colors.cardBackground, borderColor: colors.accent }, data.highlighted && { borderColor: colors.primary }]}
    >
      {data.highlighted && (
        <LinearGradient
            colors={[colors.primary, colors.primary + '88']}
            start={{ x: 0, y: 0 }} end={{ x: 1, y: 0 }}
            style={styles.highlightBorder}
        />
      )}

      {data.badge && (
        <LinearGradient
            colors={['#f59e0b', '#d97706']}
            style={styles.badge}
        >
            <Text style={styles.badgeText}>{data.badge}</Text>
        </LinearGradient>
      )}

      <View style={styles.header}>
        <Text style={[styles.name, { color: colors.text }]}>{data.name}</Text>
        <View style={styles.priceContainer}>
            <Text style={[styles.priceAmount, { color: colors.text }]}>€{data.price}</Text>
            <Text style={[styles.pricePeriod, { color: colors.secondaryText }]}>{data.period || '/mes'}</Text>
        </View>
      </View>

      <View style={[styles.highlights, { backgroundColor: colors.inputBackground }]}>
        {data.data_gb && (
            <View style={styles.highlightItem}>
                <Text style={[styles.highlightValue, { color: colors.primary }]}>{data.data_gb}GB</Text>
                <Text style={[styles.highlightLabel, { color: colors.secondaryText }]}>Datos</Text>
            </View>
        )}
        {data.calls_minutes && (
            <View style={styles.highlightItem}>
                <Text style={[styles.highlightValue, { color: colors.primary }]}>{data.calls_minutes}</Text>
                <Text style={[styles.highlightLabel, { color: colors.secondaryText }]}>Minutos</Text>
            </View>
        )}
        {data.sms && (
            <View style={styles.highlightItem}>
                <Text style={[styles.highlightValue, { color: colors.primary }]}>{data.sms}</Text>
                <Text style={[styles.highlightLabel, { color: colors.secondaryText }]}>SMS</Text>
            </View>
        )}
      </View>

      <View style={styles.features}>
        {data.features.map((feature, index) => (
            <View key={index} style={styles.featureItem}>
                <Text style={styles.featureCheck}>✓</Text>
                <Text style={[styles.featureText, { color: colors.text, opacity: 0.9 }]}>{feature}</Text>
            </View>
        ))}
      </View>

      <View style={styles.actions}>
        {actions.map(action => (
            <TouchableOpacity
                key={action.id}
                onPress={() => onAction(action.id)}
                disabled={action.disabled}
                style={styles.actionButtonWrapper}
            >
                <LinearGradient
                    colors={action.style === 'primary' ? [colors.primary, colors.primary + 'CC'] : [colors.accent, colors.accent]}
                    style={[
                        styles.actionButton,
                        action.style === 'secondary' && { borderWidth: 1, borderColor: colors.accent }
                    ]}
                >
                    <Text style={[styles.actionButtonText, action.style === 'secondary' && { color: colors.text }]}>{action.label}</Text>
                </LinearGradient>
            </TouchableOpacity>
        ))}
      </View>

      {agentMessage && (
        <View style={[styles.agentMessage, { backgroundColor: colors.inputBackground, borderLeftColor: colors.primary }]}>
          <Text style={[styles.agentMessageText, { color: colors.text }]}>{agentMessage}</Text>
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    borderRadius: 16,
    padding: 24,
    borderWidth: 1,
    marginVertical: 8,
    overflow: 'hidden',
    position: 'relative',
    width: '100%',
    shadowColor: '#000',
    shadowOpacity: 0.05,
    shadowRadius: 6,
    shadowOffset: { width: 0, height: 2 },
  },
  highlightBorder: {
      position: 'absolute',
      top: 0, left: 0, right: 0,
      height: 4,
  },
  badge: {
    position: 'absolute',
    top: 16,
    right: 16,
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 20,
  },
  badgeText: {
    color: '#000',
    fontSize: 12,
    fontWeight: '700',
    textTransform: 'uppercase',
  },
  header: {
    alignItems: 'center',
    marginBottom: 24,
  },
  name: {
    fontSize: 22,
    fontWeight: '700',
    marginBottom: 8,
  },
  priceContainer: {
    flexDirection: 'row',
    alignItems: 'baseline',
  },
  priceAmount: {
    fontSize: 36,
    fontWeight: '800',
  },
  pricePeriod: {
    fontSize: 16,
    marginLeft: 4,
  },
  highlights: {
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 24,
    marginBottom: 24,
    padding: 16,
    borderRadius: 12,
  },
  highlightItem: {
    alignItems: 'center',
  },
  highlightValue: {
    fontSize: 20,
    fontWeight: '700',
  },
  highlightLabel: {
    fontSize: 12,
    textTransform: 'uppercase',
  },
  features: {
    marginBottom: 24,
  },
  featureItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  featureCheck: {
    color: '#10b981',
    fontWeight: 'bold',
    marginRight: 12,
  },
  featureText: {
    fontSize: 14,
  },
  actions: {
    flexDirection: 'row',
    gap: 12,
  },
  actionButtonWrapper: {
    flex: 1,
    borderRadius: 12,
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOpacity: 0.1,
    shadowRadius: 2,
    shadowOffset: { width: 0, height: 1 },
  },
  actionButton: {
    paddingVertical: 14,
    alignItems: 'center',
    borderRadius: 12,
  },
  actionButtonText: {
    color: '#fff',
    fontWeight: '600',
    fontSize: 15,
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
});
