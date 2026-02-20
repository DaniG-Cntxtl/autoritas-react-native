import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView } from 'react-native';
import { useTheme } from '../../context/ThemeEngine';
import { MaterialIcons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';

export interface DocumentItem {
  description: string;
  amount?: string;
  value?: string;
}

export interface DocumentData {
  type: string; // 'INVOICE', 'CONTRACT', 'SUMMARY'
  document_id: string;
  date?: string;
  company_name?: string;
  company_address?: string;
  billed_to?: {
      name: string;
      details?: string;
  };
  items: DocumentItem[];
  subtotal?: string;
  total?: string;
  footer_note?: string;
}

interface UIAction {
  id: string;
  label: string;
  style: string;
  icon?: string;
}

interface DocumentPreviewProps {
  data: DocumentData;
  actions: UIAction[];
  agentMessage?: string | null;
  onAction: (actionId: string) => void;
}

export const DocumentPreview: React.FC<DocumentPreviewProps> = ({ data, actions, agentMessage, onAction }) => {
  const { theme } = useTheme();
  const { colors } = theme.styles;

  return (
    <View style={styles.container}>
        {/* Document Header Bar */}
        <View style={[styles.previewHeader, { backgroundColor: colors.accent }]}>
            <View style={styles.previewHeaderTitle}>
                <MaterialIcons name="insert-drive-file" size={16} color={colors.text} style={{ marginRight: 6 }} />
                <Text style={[styles.previewHeaderName, { color: colors.text }]} numberOfLines={1}>{data.document_id}.pdf</Text>
            </View>
            <Text style={[styles.previewHeaderSize, { color: colors.secondaryText }]}>PDF Document</Text>
        </View>

        {/* Paper Document */}
        <View style={[styles.paper, { backgroundColor: '#ffffff' }]}>
            <View style={[styles.docHeader, { borderBottomColor: '#f1f5f9' }]}>
                <View>
                    <Text style={styles.docType}>{data.type}</Text>
                    <Text style={styles.docId}>#{data.document_id}</Text>
                </View>
                <View style={styles.companyInfo}>
                    <Text style={[styles.companyName, { color: colors.primary }]}>{data.company_name || 'Autoritas'}</Text>
                    {data.company_address && <Text style={styles.companyAddress}>{data.company_address}</Text>}
                </View>
            </View>

            <View style={styles.metaRow}>
                {data.billed_to && (
                    <View style={styles.metaCol}>
                        <Text style={styles.metaLabel}>BILLED TO</Text>
                        <Text style={styles.metaValueMain}>{data.billed_to.name}</Text>
                        {data.billed_to.details && <Text style={styles.metaValueSub}>{data.billed_to.details}</Text>}
                    </View>
                )}
                {data.date && (
                    <View style={[styles.metaCol, { alignItems: 'flex-end' }]}>
                        <Text style={styles.metaLabel}>ISSUED</Text>
                        <Text style={styles.metaValueMain}>{data.date}</Text>
                    </View>
                )}
            </View>

            <View style={styles.table}>
                <View style={[styles.tableHeader, { borderBottomColor: '#e2e8f0' }]}>
                    <Text style={[styles.tableHeaderCell, { flex: 2 }]}>DESCRIPTION</Text>
                    <Text style={[styles.tableHeaderCell, { flex: 1, textAlign: 'right' }]}>AMOUNT</Text>
                </View>
                {data.items.map((item, idx) => (
                    <View key={idx} style={[styles.tableRow, { borderBottomColor: '#f8fafc' }]}>
                        <Text style={[styles.tableCellDesc, { flex: 2 }]}>{item.description}</Text>
                        <Text style={[styles.tableCellValue, { flex: 1, textAlign: 'right' }]}>{item.amount || item.value}</Text>
                    </View>
                ))}
            </View>

            {(data.subtotal || data.total) && (
                <View style={styles.totalsContainer}>
                    <View style={styles.totalsBox}>
                        {data.subtotal && (
                            <View style={styles.totalRow}>
                                <Text style={styles.totalLabel}>Subtotal</Text>
                                <Text style={styles.totalLabel}>{data.subtotal}</Text>
                            </View>
                        )}
                        {data.total && (
                            <View style={[styles.totalRow, styles.finalTotal, { borderTopColor: '#e2e8f0' }]}>
                                <Text style={[styles.finalTotalLabel, { color: colors.primary }]}>Total</Text>
                                <Text style={[styles.finalTotalValue, { color: colors.primary }]}>{data.total}</Text>
                            </View>
                        )}
                    </View>
                </View>
            )}

            {data.footer_note && (
                <View style={[styles.docFooter, { borderTopColor: '#f1f5f9' }]}>
                    <Text style={styles.docFooterText}>{data.footer_note}</Text>
                </View>
            )}
        </View>

        {/* Action Bar (Download/Print/Share) */}
        {actions.length > 0 && (
            <View style={[styles.actionBar, { backgroundColor: colors.cardBackground, borderColor: colors.accent }]}>
                {actions.map((action, idx) => (
                    <React.Fragment key={action.id}>
                        <TouchableOpacity 
                            style={styles.actionBtn}
                            onPress={() => onAction(action.id)}
                        >
                            <MaterialIcons name={(action.icon || 'file-download') as any} size={20} color={colors.secondaryText} />
                            <Text style={[styles.actionBtnText, { color: colors.secondaryText }]}>{action.label}</Text>
                        </TouchableOpacity>
                        {idx < actions.length - 1 && <View style={[styles.actionDivider, { backgroundColor: colors.accent }]} />}
                    </React.Fragment>
                ))}
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
    marginVertical: 12,
    width: '100%',
    alignItems: 'center',
  },
  previewHeader: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'center',
      width: '100%',
      paddingHorizontal: 16,
      paddingVertical: 10,
      borderTopLeftRadius: 12,
      borderTopRightRadius: 12,
  },
  previewHeaderTitle: {
      flexDirection: 'row',
      alignItems: 'center',
      flex: 1,
  },
  previewHeaderName: {
      fontSize: 12,
      fontWeight: '700',
      flex: 1,
  },
  previewHeaderSize: {
      fontSize: 10,
      marginLeft: 12,
  },
  paper: {
      width: '95%',
      minHeight: 400,
      padding: 24,
      shadowColor: '#000',
      shadowOpacity: 0.15,
      shadowRadius: 12,
      shadowOffset: { width: 0, height: 8 },
      elevation: 5,
      borderBottomLeftRadius: 4,
      borderBottomRightRadius: 4,
      zIndex: 2,
  },
  docHeader: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'flex-start',
      borderBottomWidth: 1,
      paddingBottom: 16,
      marginBottom: 20,
  },
  docType: {
      fontSize: 20,
      fontWeight: '900',
      color: '#0f172a',
      letterSpacing: -0.5,
  },
  docId: {
      fontSize: 10,
      color: '#64748b',
      fontFamily: 'monospace',
      marginTop: 2,
  },
  companyInfo: {
      alignItems: 'flex-end',
  },
  companyName: {
      fontSize: 12,
      fontWeight: '800',
      textTransform: 'uppercase',
      letterSpacing: 1,
  },
  companyAddress: {
      fontSize: 9,
      color: '#94a3b8',
      textAlign: 'right',
      marginTop: 4,
  },
  metaRow: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      marginBottom: 24,
  },
  metaCol: {
      flex: 1,
  },
  metaLabel: {
      fontSize: 9,
      fontWeight: '700',
      color: '#94a3b8',
      textTransform: 'uppercase',
      letterSpacing: 1,
      marginBottom: 4,
  },
  metaValueMain: {
      fontSize: 12,
      fontWeight: '700',
      color: '#0f172a',
  },
  metaValueSub: {
      fontSize: 11,
      color: '#64748b',
      marginTop: 2,
  },
  table: {
      marginBottom: 32,
  },
  tableHeader: {
      flexDirection: 'row',
      borderBottomWidth: 2,
      paddingBottom: 8,
      marginBottom: 8,
  },
  tableHeaderCell: {
      fontSize: 9,
      fontWeight: '700',
      color: '#94a3b8',
      textTransform: 'uppercase',
      letterSpacing: 1,
  },
  tableRow: {
      flexDirection: 'row',
      paddingVertical: 12,
      borderBottomWidth: 1,
  },
  tableCellDesc: {
      fontSize: 12,
      fontWeight: '500',
      color: '#0f172a',
  },
  tableCellValue: {
      fontSize: 12,
      color: '#475569',
  },
  totalsContainer: {
      flexDirection: 'row',
      justifyContent: 'flex-end',
      marginBottom: 32,
  },
  totalsBox: {
      width: '60%',
  },
  totalRow: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      marginBottom: 8,
  },
  totalLabel: {
      fontSize: 12,
      color: '#64748b',
  },
  finalTotal: {
      borderTopWidth: 1,
      paddingTop: 8,
      marginTop: 4,
  },
  finalTotalLabel: {
      fontSize: 14,
      fontWeight: '800',
  },
  finalTotalValue: {
      fontSize: 16,
      fontWeight: '800',
  },
  docFooter: {
      marginTop: 'auto',
      borderTopWidth: 1,
      paddingTop: 16,
      alignItems: 'center',
  },
  docFooterText: {
      fontSize: 9,
      color: '#94a3b8',
      textAlign: 'center',
  },
  actionBar: {
      flexDirection: 'row',
      width: '90%',
      borderWidth: 1,
      borderRadius: 16,
      marginTop: -20, // Overlap slightly with paper shadow
      zIndex: 3,
      shadowColor: '#000',
      shadowOpacity: 0.1,
      shadowRadius: 10,
      shadowOffset: { width: 0, height: 4 },
      elevation: 6,
  },
  actionBtn: {
      flex: 1,
      alignItems: 'center',
      justifyContent: 'center',
      paddingVertical: 12,
      gap: 4,
  },
  actionBtnText: {
      fontSize: 9,
      fontWeight: '800',
      textTransform: 'uppercase',
      letterSpacing: 1,
  },
  actionDivider: {
      width: 1,
      height: '100%',
  },
  agentMessage: {
    marginTop: 16,
    padding: 14,
    borderRadius: 12,
    borderLeftWidth: 3,
    width: '100%',
  },
  agentMessageText: {
    fontSize: 14,
    lineHeight: 20,
  },
});
