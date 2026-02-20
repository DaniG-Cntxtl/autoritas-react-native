import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { useTheme } from '../../context/ThemeEngine';
import { Ionicons, MaterialIcons } from '@expo/vector-icons';

interface DiagnosticData {
  model: string;
  status: 'online' | 'offline' | 'degraded';
  ip_address?: string;
  signal_strength?: number;
  last_seen?: string;
  firmware_version?: string;
  diagnostics?: Array<{
    name: string;
    status: 'ok' | 'warning' | 'error';
    value?: string;
  }>;
  quick_guide?: string[];
}

interface UIAction {
  id: string;
  label: string;
  style: string;
  icon?: string;
}

interface RouterDiagnosticsProps {
  data: DiagnosticData;
  actions: UIAction[];
  agentMessage?: string | null;
  onAction: (actionId: string) => void;
}

export const RouterDiagnostics: React.FC<RouterDiagnosticsProps> = ({ data, actions, agentMessage, onAction }) => {
  const { theme } = useTheme();
  const { colors } = theme.styles;

  const statusColor = (status: string) => {
    switch (status) {
      case 'online': case 'ok': return '#10b981';
      case 'offline': case 'error': return '#ef4444';
      case 'degraded': case 'warning': return '#f59e0b';
      default: return '#64748b';
    }
  };

  const statusIcon = (status: string) => {
    switch (status) {
      case 'online': case 'ok': return 'checkmark-circle';
      case 'offline': case 'error': return 'close-circle';
      case 'degraded': case 'warning': return 'warning';
      default: return 'help-circle';
    }
  };

  return (
    <View style={[styles.container, { backgroundColor: colors.cardBackground, borderColor: colors.accent }]}>
      <View style={styles.header}>
        <View style={styles.headerLeft}>
           <MaterialIcons name="router" size={28} color={colors.text} />
           <View style={styles.headerText}>
               <Text style={[styles.modelName, { color: colors.text }]}>{data.model}</Text>
               <View style={styles.statusRow}>
                   <View style={[styles.statusDot, { backgroundColor: statusColor(data.status) }]} />
                   <Text style={[styles.statusText, { color: statusColor(data.status) }]}>
                       {data.status === 'online' ? 'Conectado' : data.status === 'offline' ? 'Desconectado' : 'Degradado'}
                   </Text>
               </View>
           </View>
        </View>
      </View>

      {/* Router Visualization (LEDs concept from HTML) */}
      <View style={[styles.visualizationContainer, { backgroundColor: colors.background === '#ffffff' ? '#f8fafc' : 'rgba(0,0,0,0.2)', borderColor: colors.accent }]}>
          <View style={[styles.routerBox, { backgroundColor: colors.cardBackground, borderColor: colors.accent }]}>
              {/* LEDs */}
              <View style={styles.ledsContainer}>
                  <View style={[styles.led, { backgroundColor: '#3b82f6', shadowColor: '#3b82f6', shadowOpacity: 0.6, shadowRadius: 8, elevation: 5 }]} />
                  <View style={[styles.led, { backgroundColor: '#22c55e', shadowColor: '#22c55e', shadowOpacity: 0.6, shadowRadius: 8, elevation: 5 }]} />
                  <View style={[styles.led, { backgroundColor: colors.accent }]} />
                  <View style={[styles.led, { backgroundColor: '#ef4444' }]} />
              </View>
          </View>

          {/* Simple Callouts */}
          <View style={styles.calloutList}>
              <View style={styles.calloutItem}>
                  <View style={[styles.calloutDot, { backgroundColor: '#3b82f6' }]} />
                  <Text style={[styles.calloutText, { color: colors.text }]}>WPS</Text>
              </View>
              <View style={styles.calloutItem}>
                  <View style={[styles.calloutDot, { backgroundColor: '#22c55e' }]} />
                  <Text style={[styles.calloutText, { color: colors.text }]}>Internet</Text>
              </View>
              <View style={styles.calloutItem}>
                  <View style={[styles.calloutDot, { backgroundColor: colors.accent }]} />
                  <Text style={[styles.calloutText, { color: colors.text }]}>LAN</Text>
              </View>
              <View style={styles.calloutItem}>
                  <View style={[styles.calloutDot, { backgroundColor: '#ef4444' }]} />
                  <Text style={[styles.calloutText, { color: colors.text }]}>Power</Text>
              </View>
          </View>
      </View>

      {/* Quick Guide / Diagnostics */}
      {data.quick_guide && data.quick_guide.length > 0 && (
          <View style={styles.guideContainer}>
              <Text style={[styles.sectionTitle, { color: colors.text, borderBottomColor: colors.accent }]}>QUICK GUIDE</Text>
              {data.quick_guide.map((item, idx) => (
                  <View key={idx} style={styles.guideItem}>
                      <Ionicons name="information-circle" size={16} color={colors.primary} style={{ marginTop: 2, marginRight: 8 }} />
                      <Text style={[styles.guideText, { color: colors.text, opacity: 0.8 }]}>{item}</Text>
                  </View>
              ))}
          </View>
      )}

      {/* Status Details */}
      {data.diagnostics && data.diagnostics.length > 0 && (
          <View style={styles.diagnosticsContainer}>
             <Text style={[styles.sectionTitle, { color: colors.text, borderBottomColor: colors.accent }]}>DIAGNOSTICS</Text>
             {data.diagnostics.map((diag, idx) => (
                 <View key={idx} style={styles.diagItem}>
                     <View style={styles.diagNameRow}>
                         <Ionicons name={statusIcon(diag.status) as any} size={16} color={statusColor(diag.status)} style={{ marginRight: 6 }} />
                         <Text style={[styles.diagName, { color: colors.text }]}>{diag.name}</Text>
                     </View>
                     {diag.value && <Text style={[styles.diagValue, { color: colors.secondaryText }]}>{diag.value}</Text>}
                 </View>
             ))}
          </View>
      )}

      {/* Action Buttons */}
      {actions.length > 0 && (
          <View style={[styles.actionsContainer, { backgroundColor: colors.background === '#ffffff' ? '#1c2936' : '#1c2936' }]}>
              {actions.map((action, idx) => (
                  <React.Fragment key={action.id}>
                      <TouchableOpacity 
                        onPress={() => onAction(action.id)}
                        style={styles.actionButton}
                      >
                           {action.icon ? (
                               <MaterialIcons name={action.icon as any} size={24} color={action.style === 'primary' ? colors.primary : '#9ca3af'} />
                           ) : (
                               <MaterialIcons name="play-circle-outline" size={24} color={action.style === 'primary' ? colors.primary : '#9ca3af'} />
                           )}
                           <Text style={[styles.actionButtonText, { color: action.style === 'primary' ? '#fff' : '#9ca3af' }]}>{action.label}</Text>
                      </TouchableOpacity>
                      {idx < actions.length - 1 && <View style={styles.actionDivider} />}
                  </React.Fragment>
              ))}
          </View>
      )}

      {agentMessage && (
        <View style={[styles.agentMessage, { backgroundColor: colors.inputBackground, borderLeftColor: colors.primary }]}>
          <View style={{ flexDirection: 'row', alignItems: 'center', marginBottom: 4 }}>
             <MaterialIcons name="psychology" size={16} color={colors.primary} style={{ marginRight: 6 }} />
             <Text style={[styles.agentMessageTitle, { color: colors.primary }]}>AI RECOMMENDATION</Text>
          </View>
          <Text style={[styles.agentMessageText, { color: colors.text }]}>{agentMessage}</Text>
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    borderRadius: 24,
    padding: 20,
    borderWidth: 1,
    marginVertical: 8,
    width: '100%',
    shadowColor: '#000',
    shadowOpacity: 0.05,
    shadowRadius: 8,
    shadowOffset: { width: 0, height: 4 },
    elevation: 3,
  },
  header: {
    marginBottom: 20,
  },
  headerLeft: {
      flexDirection: 'row',
      alignItems: 'center',
  },
  headerText: {
      marginLeft: 12,
  },
  modelName: {
    fontSize: 18,
    fontWeight: '800',
    letterSpacing: -0.5,
  },
  statusRow: {
      flexDirection: 'row',
      alignItems: 'center',
      marginTop: 4,
  },
  statusDot: {
      width: 8,
      height: 8,
      borderRadius: 4,
      marginRight: 6,
  },
  statusText: {
      fontSize: 12,
      fontWeight: '600',
      textTransform: 'uppercase',
      letterSpacing: 1,
  },
  visualizationContainer: {
      width: '100%',
      aspectRatio: 1.5,
      borderRadius: 16,
      borderWidth: 1,
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'center',
      padding: 16,
      marginBottom: 20,
  },
  routerBox: {
      width: 120,
      height: 120,
      borderRadius: 24,
      borderWidth: 1,
      justifyContent: 'center',
      alignItems: 'center',
      shadowColor: '#000',
      shadowOpacity: 0.05,
      shadowRadius: 4,
      elevation: 2,
  },
  ledsContainer: {
      flexDirection: 'row',
      gap: 12,
  },
  led: {
      width: 10,
      height: 10,
      borderRadius: 5,
  },
  calloutList: {
      marginLeft: 24,
      justifyContent: 'center',
      gap: 12,
  },
  calloutItem: {
      flexDirection: 'row',
      alignItems: 'center',
  },
  calloutDot: {
      width: 8,
      height: 8,
      borderRadius: 4,
      marginRight: 8,
  },
  calloutText: {
      fontSize: 12,
      fontWeight: '600',
  },
  sectionTitle: {
      fontSize: 10,
      fontWeight: '800',
      letterSpacing: 1.5,
      marginBottom: 12,
      paddingBottom: 6,
      borderBottomWidth: 1,
  },
  guideContainer: {
      marginBottom: 20,
  },
  guideItem: {
      flexDirection: 'row',
      marginBottom: 8,
  },
  guideText: {
      fontSize: 13,
      lineHeight: 18,
      flex: 1,
  },
  diagnosticsContainer: {
      marginBottom: 20,
  },
  diagItem: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'center',
      paddingVertical: 8,
  },
  diagNameRow: {
      flexDirection: 'row',
      alignItems: 'center',
  },
  diagName: {
      fontSize: 14,
      fontWeight: '500',
  },
  diagValue: {
      fontSize: 13,
  },
  actionsContainer: {
      flexDirection: 'row',
      borderRadius: 16,
      overflow: 'hidden',
      padding: 4,
      marginTop: 8,
  },
  actionButton: {
      flex: 1,
      alignItems: 'center',
      justifyContent: 'center',
      paddingVertical: 12,
      gap: 4,
  },
  actionDivider: {
      width: 1,
      backgroundColor: 'rgba(255,255,255,0.1)',
      marginVertical: 8,
  },
  actionButtonText: {
      fontSize: 9,
      fontWeight: '700',
      textTransform: 'uppercase',
      letterSpacing: 1,
  },
  agentMessage: {
    marginTop: 16,
    padding: 16,
    borderRadius: 12,
    borderLeftWidth: 4,
  },
  agentMessageTitle: {
      fontSize: 10,
      fontWeight: '800',
      letterSpacing: 1,
  },
  agentMessageText: {
    fontSize: 13,
    lineHeight: 18,
  },
});
