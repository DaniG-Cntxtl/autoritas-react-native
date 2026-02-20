import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView, Dimensions } from 'react-native';
import { useTheme } from '../../context/ThemeEngine';
import { MaterialIcons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';

const { width } = Dimensions.get('window');
const CARD_WIDTH = (width - 32 - 16) / 2; // (Screen Width - Padding - Gap) / 2

export interface TelemetryData {
  data_usage?: {
    used: number;
    total: number;
    unit: string;
    percentage: number;
  };
  network_status?: {
    status: string;
    network_type: string;
    location: string;
    signal_level: 1 | 2 | 3 | 4; // 1-4 bars
  };
}

interface UIAction {
  id: string;
  label: string;
  style: string;
  icon?: string;
  description?: string;
}

interface TelemetryDashboardProps {
  data: TelemetryData;
  actions: UIAction[];
  agentMessage?: string | null;
  onAction: (actionId: string) => void;
}

export const TelemetryDashboard: React.FC<TelemetryDashboardProps> = ({ data, actions, agentMessage, onAction }) => {
  const { theme } = useTheme();
  const { colors } = theme.styles;

  const getSignalColor = (level: number) => {
      if (level >= 3) return '#22c55e'; // Green
      if (level === 2) return '#f59e0b'; // Orange
      return '#ef4444'; // Red
  };

  const getActionColor = (style: string) => {
      switch(style) {
          case 'primary': return colors.primary;
          case 'success': return '#22c55e';
          case 'danger': return '#ef4444';
          case 'warning': return '#f59e0b';
          case 'purple': return '#a855f7';
          default: return colors.text;
      }
  };

  // Circular progress approximation using border styling (for pure RN without SVG)
  // For a real production app, react-native-svg is recommended for perfect rings.
  return (
    <View style={styles.container}>
      <View style={styles.grid}>
        {/* Data Usage Card */}
        {data.data_usage && (
            <View style={[styles.card, { backgroundColor: colors.cardBackground, borderColor: colors.accent }]}>
                <View style={styles.cardHeader}>
                    <View style={[styles.iconBox, { backgroundColor: colors.primary + '1A' }]}>
                        <MaterialIcons name="data-usage" size={20} color={colors.primary} />
                    </View>
                    <MaterialIcons name="arrow-outward" size={16} color={colors.secondaryText} />
                </View>
                
                <View style={styles.centerContent}>
                    {/* Placeholder for Circular Progress */}
                    <View style={[styles.progressRing, { borderColor: colors.accent, borderTopColor: colors.primary }]}>
                         <View style={styles.progressInner}>
                              <Text style={[styles.progressText, { color: colors.text }]}>{data.data_usage.percentage}%</Text>
                         </View>
                    </View>
                </View>

                <View style={styles.cardFooter}>
                    <Text style={[styles.cardLabel, { color: colors.secondaryText }]}>Data Usage</Text>
                    <Text style={[styles.cardValue, { color: colors.text }]}>{data.data_usage.used} / {data.data_usage.total} {data.data_usage.unit}</Text>
                </View>
            </View>
        )}

        {/* Network Status Card */}
        {data.network_status && (
            <View style={[styles.card, { backgroundColor: colors.cardBackground, borderColor: colors.accent }]}>
                <View style={styles.cardHeader}>
                    <View style={[styles.iconBox, { backgroundColor: '#22c55e1A' }]}>
                        <MaterialIcons name="signal-cellular-alt" size={20} color="#22c55e" />
                    </View>
                    <MaterialIcons name="refresh" size={16} color={colors.secondaryText} />
                </View>
                
                <View style={styles.centerContent}>
                    <View style={styles.signalBars}>
                        {[1, 2, 3, 4].map(bar => (
                            <View 
                                key={bar} 
                                style={[
                                    styles.signalBar, 
                                    { 
                                        height: 12 + (bar * 8), 
                                        backgroundColor: bar <= (data.network_status?.signal_level || 0) ? getSignalColor(data.network_status?.signal_level || 0) : colors.accent 
                                    }
                                ]} 
                            />
                        ))}
                    </View>
                    <Text style={[styles.statusMain, { color: getSignalColor(data.network_status.signal_level) }]}>{data.network_status.status}</Text>
                </View>

                <View style={styles.cardFooter}>
                    <Text style={[styles.cardLabel, { color: colors.secondaryText }]}>Network Status</Text>
                    <Text style={[styles.cardValue, { color: colors.text }]}>{data.network_status.network_type} • {data.network_status.location}</Text>
                </View>
            </View>
        )}
      </View>

      {/* Quick Actions Carousel */}
      {actions.length > 0 && (
          <View style={styles.actionsSection}>
              <Text style={[styles.sectionTitle, { color: colors.secondaryText }]}>QUICK ACTIONS</Text>
              <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.actionsScroll}>
                  {actions.map(action => (
                      <TouchableOpacity 
                        key={action.id} 
                        style={[styles.actionCard, { backgroundColor: colors.cardBackground, borderColor: colors.accent }]}
                        onPress={() => onAction(action.id)}
                      >
                          <MaterialIcons name={(action.icon || 'star') as any} size={24} color={getActionColor(action.style)} style={{ marginRight: 12 }} />
                          <View>
                              <Text style={[styles.actionLabel, { color: colors.text }]}>{action.label}</Text>
                              {action.description && <Text style={[styles.actionDesc, { color: colors.secondaryText }]}>{action.description}</Text>}
                          </View>
                      </TouchableOpacity>
                  ))}
              </ScrollView>
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
  grid: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  card: {
    width: CARD_WIDTH,
    aspectRatio: 1,
    borderRadius: 24,
    borderWidth: 1,
    padding: 16,
    justifyContent: 'space-between',
    shadowColor: '#000',
    shadowOpacity: 0.05,
    shadowRadius: 8,
    shadowOffset: { width: 0, height: 4 },
    elevation: 3,
  },
  cardHeader: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'flex-start',
  },
  iconBox: {
      width: 36,
      height: 36,
      borderRadius: 12,
      alignItems: 'center',
      justifyContent: 'center',
  },
  centerContent: {
      alignItems: 'center',
      justifyContent: 'center',
      flex: 1,
  },
  progressRing: {
      width: 80,
      height: 80,
      borderRadius: 40,
      borderWidth: 6,
      alignItems: 'center',
      justifyContent: 'center',
  },
  progressInner: {
      alignItems: 'center',
      justifyContent: 'center',
  },
  progressText: {
      fontSize: 18,
      fontWeight: '800',
  },
  signalBars: {
      flexDirection: 'row',
      alignItems: 'flex-end',
      height: 44,
      gap: 4,
  },
  signalBar: {
      width: 8,
      borderRadius: 4,
  },
  statusMain: {
      fontSize: 16,
      fontWeight: '800',
      marginTop: 8,
  },
  cardFooter: {
      alignItems: 'center',
  },
  cardLabel: {
      fontSize: 11,
      fontWeight: '500',
  },
  cardValue: {
      fontSize: 12,
      fontWeight: '800',
      marginTop: 2,
  },
  actionsSection: {
      marginTop: 8,
  },
  sectionTitle: {
      fontSize: 10,
      fontWeight: '800',
      textTransform: 'uppercase',
      letterSpacing: 1,
      marginBottom: 12,
      marginLeft: 4,
  },
  actionsScroll: {
      paddingBottom: 8,
      gap: 12,
  },
  actionCard: {
      flexDirection: 'row',
      alignItems: 'center',
      paddingHorizontal: 16,
      paddingVertical: 12,
      borderRadius: 16,
      borderWidth: 1,
      minWidth: 160,
      shadowColor: '#000',
      shadowOpacity: 0.05,
      shadowRadius: 4,
      shadowOffset: { width: 0, height: 2 },
      elevation: 2,
  },
  actionLabel: {
      fontSize: 14,
      fontWeight: '700',
  },
  actionDesc: {
      fontSize: 10,
      marginTop: 2,
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