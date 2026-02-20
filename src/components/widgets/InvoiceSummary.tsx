import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { useTheme } from '../../context/ThemeEngine';

interface InvoiceData {
  invoice_id: string;
  period: string;
  total: number;
  due_date?: string;
  status?: 'paid' | 'pending' | 'overdue';
  pdf_url?: string;
  line_items?: Array<{
    description: string;
    amount: number;
  }>;
}

interface UIAction {
  id: string;
  label: string;
  style: string;
}

interface InvoiceSummaryProps {
  data: InvoiceData;
  actions: UIAction[];
  agentMessage?: string | null;
  onAction: (actionId: string) => void;
}

export const InvoiceSummary: React.FC<InvoiceSummaryProps> = ({ data, actions, agentMessage, onAction }) => {
  const { theme } = useTheme();
  const { colors } = theme.styles;

  const getStatusColor = (status?: string) => {
    switch (status) {
      case 'paid': return '#10b981';
      case 'overdue': return '#ef4444';
      default: return '#f59e0b';
    }
  };

  const getStatusLabel = (status?: string) => {
      switch (status) {
        case 'paid': return 'Pagada';
        case 'overdue': return 'Vencida';
        default: return 'Pendiente';
      }
  };

  return (
    <View style={[styles.container, { backgroundColor: colors.cardBackground, borderColor: colors.accent }]}>
      <View style={styles.header}>
        <View>
            <Text style={[styles.title, { color: colors.text }]}>Factura</Text>
            <Text style={[styles.invoiceId, { color: colors.secondaryText }]}>#{data.invoice_id}</Text>
        </View>
        {data.status && (
            <View style={[styles.statusBadge, { backgroundColor: getStatusColor(data.status) }]}>
                <Text style={styles.statusText}>{getStatusLabel(data.status)}</Text>
            </View>
        )}
      </View>

      <View style={styles.body}>
        <View style={[styles.row, { borderBottomColor: colors.accent }]}>
            <Text style={[styles.label, { color: colors.secondaryText }]}>Período</Text>
            <Text style={[styles.value, { color: colors.text }]}>{data.period}</Text>
        </View>

        {data.due_date && (
            <View style={[styles.row, { borderBottomColor: colors.accent }]}>
                <Text style={[styles.label, { color: colors.secondaryText }]}>Vencimiento</Text>
                <Text style={[styles.value, { color: colors.text }]}>{data.due_date}</Text>
            </View>
        )}

        <View style={styles.itemsContainer}>
            {data.line_items?.map((item, index) => (
                <View key={index} style={styles.itemRow}>
                    <Text style={[styles.itemDesc, { color: colors.text, opacity: 0.8 }]}>{item.description}</Text>
                    <Text style={[styles.itemAmount, { color: colors.text }]}>€{item.amount.toFixed(2)}</Text>
                </View>
            ))}
        </View>

        <View style={[styles.totalRow, { borderTopColor: colors.accent }]}>
            <Text style={[styles.totalLabel, { color: colors.text }]}>Total</Text>
            <Text style={[styles.totalAmount, { color: colors.primary }]}>€{data.total.toFixed(2)}</Text>
        </View>
      </View>

      <View style={styles.actions}>
        {actions.map(action => (
            <TouchableOpacity
                key={action.id}
                onPress={() => onAction(action.id)}
                style={styles.actionButtonWrapper}
            >
                <LinearGradient
                    colors={action.style === 'primary' ? [colors.primary, colors.primary + 'CC'] : [colors.accent, colors.accent]}
                    style={styles.actionButton}
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
    width: '100%',
    shadowColor: '#000',
    shadowOpacity: 0.05,
    shadowRadius: 6,
    shadowOffset: { width: 0, height: 2 },
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 24,
  },
  title: {
    fontSize: 20,
    fontWeight: '700',
  },
  invoiceId: {
    fontSize: 14,
    marginTop: 2,
  },
  statusBadge: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
  },
  statusText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: '600',
    textTransform: 'uppercase',
  },
  body: {
    marginBottom: 24,
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 12,
    borderBottomWidth: 1,
  },
  label: {
    fontSize: 14,
  },
  value: {
    fontWeight: '500',
    fontSize: 14,
  },
  itemsContainer: {
    paddingVertical: 12,
  },
  itemRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 8,
  },
  itemDesc: {
    fontSize: 14,
  },
  itemAmount: {
    fontSize: 14,
    fontWeight: '500',
  },
  totalRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingTop: 16,
    marginTop: 8,
    borderTopWidth: 2,
  },
  totalLabel: {
    fontSize: 18,
    fontWeight: '600',
  },
  totalAmount: {
    fontSize: 24,
    fontWeight: '700',
  },
  actions: {
    flexDirection: 'row',
    gap: 12,
  },
  actionButtonWrapper: {
    flex: 1,
    borderRadius: 10,
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOpacity: 0.1,
    shadowRadius: 2,
    shadowOffset: { width: 0, height: 1 },
  },
  actionButton: {
    paddingVertical: 12,
    alignItems: 'center',
  },
  actionButtonText: {
    color: '#fff',
    fontWeight: '600',
    fontSize: 14,
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
