import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { useTheme } from '../../context/ThemeEngine';
import { Ionicons } from '@expo/vector-icons';

export interface PlanOption {
  plan_id: string;
  name: string;
  price: number;
  period?: string;
  features: string[];
  data_gb?: number;
  badge?: string;
  highlighted?: boolean;
}

interface UIAction {
  id: string;
  label: string;
  style: string;
  icon?: string;
}

interface PlanGridProps {
  data: {
    plans: PlanOption[];
    title?: string;
  };
  actions: UIAction[];
  selectedActionId?: string | null;
  agentMessage?: string | null;
  onAction: (actionId: string, payload?: any) => void;
}

export const PlanGrid: React.FC<PlanGridProps> = ({
  data,
  actions,
  agentMessage,
  onAction,
}) => {
  const { theme } = useTheme();
  const { colors } = theme.styles;
  const [selectedPlan, setSelectedPlan] = useState<PlanOption | null>(null);

  const handleSelectPlan = (plan: PlanOption) => {
    if (selectedPlan?.plan_id === plan.plan_id) {
       // Confirm selection
       onAction(plan.plan_id, plan);
    } else {
       setSelectedPlan(plan);
    }
  };

  const handleConfirm = () => {
    if (selectedPlan) {
      onAction(selectedPlan.plan_id, selectedPlan);
    }
  };

  return (
    <View style={[styles.container, { backgroundColor: colors.background === '#ffffff' ? '#ffffff' : 'transparent', borderWidth: 0 }]}>
      {data.title && (
        <Text style={[styles.widgetTitle, { color: colors.text }]}>{data.title}</Text>
      )}

      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.scrollContent}>
        {data.plans.map((plan, index) => {
          const isSelected = selectedPlan?.plan_id === plan.plan_id;

          return (
            <TouchableOpacity
              key={plan.plan_id || index}
              onPress={() => handleSelectPlan(plan)}
              activeOpacity={0.9}
              style={styles.cardWrapper}
            >
                <View
                    style={[
                        styles.planCard,
                        { backgroundColor: colors.cardBackground, borderColor: colors.accent },
                        isSelected && { borderColor: '#10b981', backgroundColor: colors.background === '#ffffff' ? '#ecfdf5' : '#1a3a2a' },
                        plan.highlighted && !isSelected && { borderColor: colors.primary }
                    ]}
                >
                {/* Selection Border Overlay */}
                {isSelected && (
                    <LinearGradient 
                         colors={['#10b981', '#34d399']} 
                         start={{x: 0, y: 0}} end={{x: 1, y: 0}}
                         style={styles.selectionBorder} 
                    />
                )}
                {plan.highlighted && !isSelected && (
                    <LinearGradient 
                         colors={[colors.primary, colors.primary + '88']} 
                         start={{x: 0, y: 0}} end={{x: 1, y: 0}}
                         style={styles.selectionBorder} 
                    />
                )}

                {plan.badge && (
                    <LinearGradient
                        colors={isSelected ? ['#10b981', '#34d399'] : ['#f59e0b', '#d97706']}
                        style={styles.badge}
                    >
                        <Text style={styles.badgeText}>{isSelected ? 'Selected' : plan.badge}</Text>
                    </LinearGradient>
                )}

                <View style={styles.header}>
                    <Text style={[styles.name, { color: colors.text }]}>{plan.name}</Text>
                    <View style={styles.priceContainer}>
                        <Text style={[styles.priceAmount, { color: colors.text }]}>€{plan.price}</Text>
                        <Text style={[styles.pricePeriod, { color: colors.secondaryText }]}>{plan.period || '/mes'}</Text>
                    </View>
                </View>

                {plan.data_gb && (
                    <View style={[styles.highlightItem, { backgroundColor: colors.inputBackground }]}>
                        <Text style={[styles.highlightValue, { color: colors.primary }]}>{plan.data_gb}GB</Text>
                        <Text style={[styles.highlightLabel, { color: colors.secondaryText }]}>Datos</Text>
                    </View>
                )}

                <View style={styles.features}>
                    {plan.features.slice(0, 3).map((feature, idx) => (
                        <View key={idx} style={styles.featureItem}>
                            <Ionicons name="checkmark-circle" size={16} color={isSelected ? "#10b981" : colors.primary} style={{ marginRight: 8 }} />
                            <Text style={[styles.featureText, { color: colors.text, opacity: 0.9 }]} numberOfLines={2}>{feature}</Text>
                        </View>
                    ))}
                    {plan.features.length > 3 && (
                         <Text style={[styles.moreFeaturesText, { color: colors.secondaryText }]}>+{plan.features.length - 3} more...</Text>
                    )}
                </View>

                {isSelected && (
                    <View style={styles.selectedIconContainer}>
                        <Ionicons name="checkmark-circle" size={32} color="#10b981" />
                    </View>
                )}
                </View>
            </TouchableOpacity>
          );
        })}
      </ScrollView>

      {selectedPlan && (
        <View style={styles.confirmContainer}>
            <TouchableOpacity onPress={handleConfirm} style={{ width: '100%' }}>
                <LinearGradient
                    colors={['#10b981', '#059669']}
                    style={styles.confirmButton}
                >
                    <Text style={styles.confirmButtonText}>Confirmar {selectedPlan.name}</Text>
                </LinearGradient>
            </TouchableOpacity>
        </View>
      )}

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
    marginVertical: 8,
    width: '100%',
  },
  widgetTitle: {
    fontSize: 18,
    fontWeight: '700',
    marginBottom: 12,
    paddingHorizontal: 16,
  },
  scrollContent: {
    paddingHorizontal: 16,
    gap: 12,
  },
  cardWrapper: {
    width: 260,
  },
  planCard: {
    borderRadius: 16,
    padding: 20,
    borderWidth: 1,
    minHeight: 280,
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOpacity: 0.05,
    shadowRadius: 6,
    shadowOffset: { width: 0, height: 2 },
    position: 'relative',
  },
  selectionBorder: {
      position: 'absolute',
      top: 0, left: 0, right: 0,
      height: 4,
  },
  badge: {
    position: 'absolute',
    top: 12,
    right: 12,
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 12,
  },
  badgeText: {
    color: '#000',
    fontSize: 10,
    fontWeight: '700',
    textTransform: 'uppercase',
  },
  header: {
    marginBottom: 16,
    marginTop: 8,
  },
  name: {
    fontSize: 18,
    fontWeight: '700',
    marginBottom: 4,
  },
  priceContainer: {
    flexDirection: 'row',
    alignItems: 'baseline',
  },
  priceAmount: {
    fontSize: 32,
    fontWeight: '800',
  },
  pricePeriod: {
    fontSize: 14,
    marginLeft: 2,
  },
  highlightItem: {
    alignItems: 'center',
    paddingVertical: 8,
    borderRadius: 8,
    marginBottom: 16,
  },
  highlightValue: {
    fontSize: 18,
    fontWeight: '700',
  },
  highlightLabel: {
    fontSize: 10,
    textTransform: 'uppercase',
    marginTop: 2,
  },
  features: {
    flex: 1,
  },
  featureItem: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    marginBottom: 10,
  },
  featureText: {
    fontSize: 13,
    flex: 1,
    lineHeight: 18,
  },
  moreFeaturesText: {
    fontSize: 12,
    fontStyle: 'italic',
    marginTop: 4,
  },
  selectedIconContainer: {
      position: 'absolute',
      bottom: 16,
      right: 16,
  },
  confirmContainer: {
      marginTop: 16,
      paddingHorizontal: 16,
      alignItems: 'center',
  },
  confirmButton: {
      paddingVertical: 14,
      borderRadius: 12,
      alignItems: 'center',
      width: '100%',
  },
  confirmButtonText: {
      color: 'white',
      fontWeight: '700',
      fontSize: 16,
  },
  agentMessage: {
    marginTop: 16,
    marginHorizontal: 16,
    padding: 14,
    borderRadius: 12,
    borderLeftWidth: 3,
  },
  agentMessageText: {
    fontSize: 14,
    lineHeight: 20,
  },
});
