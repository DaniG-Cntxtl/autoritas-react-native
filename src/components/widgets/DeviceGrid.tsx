import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Dimensions } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Image } from 'expo-image';
import { useTheme } from '../../context/ThemeEngine';

const { width } = Dimensions.get('window');
// Calculate card width for 2-column layout with some spacing
const CARD_WIDTH = (width - 64) / 2; // (Screen width - padding) / 2

export interface Device {
  sku?: string;
  id?: string;
  name: string;
  brand: string;
  image_url?: string;
  full_price?: number;
  price?: number;
  monthly?: number;
  price_with_plan?: number;
  storage?: string;
  color?: string;
  in_stock?: boolean;
}

interface UIAction {
  id: string;
  label: string;
  style: string;
  icon?: string;
}

interface DeviceGridProps {
  data: {
    devices: Device[];
    title?: string;
  };
  actions: UIAction[];
  selectedActionId?: string | null;
  agentMessage?: string | null;
  onAction: (actionId: string, device?: Device) => void;
}

const deviceImages: Record<string, string> = {
  'iPhone 14': 'https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/iphone-14-finish-select-202209-6-1inch-blue?wid=400&hei=400&fmt=p-jpg',
  'iPhone 15 Pro': 'https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/iphone-15-pro-finish-select-202309-6-1inch-naturaltitanium?wid=400&hei=400&fmt=p-jpg',
  'iPhone 15': 'https://store.storeimages.cdn-apple.com/4668/as-images.apple.com/is/iphone-15-finish-select-202309-6-1inch-pink?wid=400&hei=400&fmt=p-jpg',
  'Samsung Galaxy S24': 'https://images.samsung.com/es/smartphones/galaxy-s24/images/galaxy-s24-highlights-design-back-702-mo.webp',
  'Samsung Galaxy A54': 'https://images.samsung.com/is/image/samsung/p6pim/es/sm-a546blvceub/gallery/es-galaxy-a54-5g-sm-a546-sm-a546blvceub-535227270?$684_547_PNG$',
  'default': 'https://via.placeholder.com/200x200?text=Phone'
};

const getDeviceImage = (device: Device) => {
  if (device.image_url) return device.image_url;
  return deviceImages[device.name] || deviceImages['default'];
};

export const DeviceGrid: React.FC<DeviceGridProps> = React.memo(({
  data,
  actions,
  agentMessage,
  onAction,
}) => {
  const { theme } = useTheme();
  const { colors } = theme.styles;
  const [selectedDevice, setSelectedDevice] = useState<Device | null>(null);

  const handleSelectDevice = (device: Device) => {
    if (device.in_stock === false) return;
    
    if (selectedDevice?.name === device.name) {
       // Confirm selection
       onAction(device.name, device);
    } else {
       setSelectedDevice(device);
    }
  };

  const handleConfirm = () => {
    if (selectedDevice) {
      onAction(selectedDevice.name, selectedDevice);
    }
  };

  const getFullPrice = (device: Device) => device.full_price ?? device.price ?? 0;
  const getMonthlyPrice = (device: Device) => device.monthly ?? device.price_with_plan ?? null;

  return (
    <View style={[styles.container, { backgroundColor: colors.cardBackground, borderColor: colors.accent }]}>
      {data.title && (
        <Text style={[styles.widgetTitle, { color: colors.text }]}>{data.title}</Text>
      )}

      <View style={styles.grid}>
        {data.devices.map((device, index) => {
          const isSelected = selectedDevice?.name === device.name;
          const isOutOfStock = device.in_stock === false;
          const monthly = getMonthlyPrice(device);

          return (
            <TouchableOpacity
              key={device.sku || device.id || index}
              onPress={() => handleSelectDevice(device)}
              activeOpacity={0.8}
              style={[
                  styles.cardWrapper,
                  { width: '48%' } // Fallback if calc doesn't work perfectly in flex wrap
              ]}
            >
                <View
                    style={[
                        styles.deviceCard,
                        { backgroundColor: colors.cardBackground, borderColor: colors.accent },
                        isSelected && { borderColor: '#10b981', backgroundColor: colors.background === '#ffffff' ? '#ecfdf5' : '#1a3a2a' },
                        isOutOfStock && styles.deviceCardOutOfStock
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

                <View style={styles.imageContainer}>
                    <Image 
                        source={{ uri: getDeviceImage(device) }} 
                        style={styles.deviceImage} 
                        contentFit="contain"
                        transition={200}
                    />
                </View>

                <View style={styles.deviceInfo}>
                    <Text style={[styles.deviceBrand, { color: colors.secondaryText }]}>{device.brand}</Text>
                    <Text style={[styles.deviceName, { color: colors.text }]} numberOfLines={2}>{device.name}</Text>
                    
                    {(device.storage || device.color) && (
                        <View style={styles.specsRow}>
                            {device.storage && <Text style={[styles.specBadge, { backgroundColor: colors.inputBackground, color: colors.secondaryText, borderColor: colors.accent }]}>{device.storage}</Text>}
                            {device.color && <Text style={[styles.specBadge, { backgroundColor: colors.inputBackground, color: colors.secondaryText, borderColor: colors.accent }]}>{device.color}</Text>}
                        </View>
                    )}

                    <View style={[styles.pricingContainer, { borderTopColor: colors.accent }]}>
                        <View style={styles.priceRow}>
                            <Text style={[styles.priceLabel, { color: colors.secondaryText }]}>Total</Text>
                            <Text style={[styles.priceFull, { color: colors.text }]}>{getFullPrice(device)}€</Text>
                        </View>
                        {monthly && (
                            <View style={[styles.monthlyContainer, { backgroundColor: colors.background === '#ffffff' ? '#ecfdf5' : 'rgba(16, 185, 129, 0.1)' }]}>
                                <Text style={[styles.priceLabel, { color: '#059669' }]}>Desde</Text>
                                <Text style={[styles.priceMonthly, { color: '#10b981' }]}>
                                    {monthly.toFixed(2)}€<Text style={styles.perMonth}>/mes</Text>
                                </Text>
                            </View>
                        )}
                        <Text style={[styles.financingNote, { color: colors.secondaryText }]}>24 meses sin intereses</Text>
                    </View>
                </View>

                {isSelected && (
                    <View style={styles.selectedBadge}>
                        <Text style={styles.selectedBadgeText}>✓ Seleccionado</Text>
                    </View>
                )}
                
                {isOutOfStock && (
                    <View style={styles.outOfStockBadge}>
                        <Text style={styles.outOfStockText}>Sin stock</Text>
                    </View>
                )}
                </View>
            </TouchableOpacity>
          );
        })}
      </View>

      {selectedDevice && (
        <View style={styles.confirmContainer}>
            <TouchableOpacity onPress={handleConfirm}>
                <LinearGradient
                    colors={['#10b981', '#059669']}
                    style={styles.confirmButton}
                >
                    <Text style={styles.confirmButtonText}>Confirmar {selectedDevice.name}</Text>
                </LinearGradient>
            </TouchableOpacity>
        </View>
      )}

      {actions.length > 0 && (
          <View style={[styles.actionsContainer, { borderTopColor: colors.accent }]}>
              {actions.map(action => (
                  <TouchableOpacity 
                    key={action.id} 
                    onPress={() => onAction(action.id)}
                    style={styles.actionButton}
                  >
                       <LinearGradient
                           colors={action.style === 'primary' ? [colors.primary, colors.primary + 'CC'] : [colors.accent, colors.accent]}
                           style={styles.actionButtonGradient}
                       >
                           {action.icon && <Text style={{color: action.style === 'primary' ? 'white' : colors.secondaryText, marginRight: 5}}>{action.icon}</Text>}
                           <Text style={[styles.actionButtonText, { color: action.style === 'primary' ? 'white' : colors.text }]}>{action.label}</Text>
                       </LinearGradient>
                  </TouchableOpacity>
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
});

const styles = StyleSheet.create({
  container: {
    padding: 16,
    borderRadius: 20,
    borderWidth: 1,
    marginVertical: 8,
    width: '100%',
    shadowColor: '#000',
    shadowOpacity: 0.05,
    shadowRadius: 6,
    shadowOffset: { width: 0, height: 2 },
  },
  widgetTitle: {
    fontSize: 20,
    fontWeight: '700',
    marginBottom: 16,
    textAlign: 'center',
  },
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    gap: 12,
  },
  cardWrapper: {
    marginBottom: 12,
  },
  deviceCard: {
    borderRadius: 20,
    padding: 12,
    borderWidth: 1,
    minHeight: 320,
    justifyContent: 'space-between',
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOpacity: 0.05,
    shadowRadius: 4,
    shadowOffset: { width: 0, height: 2 },
  },
  deviceCardOutOfStock: {
      opacity: 0.5,
  },
  selectionBorder: {
      position: 'absolute',
      top: 0, left: 0, right: 0,
      height: 3,
  },
  imageContainer: {
    height: 120,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 10,
  },
  deviceImage: {
    width: '100%',
    height: '100%',
  },
  deviceInfo: {
    alignItems: 'center',
  },
  deviceBrand: {
    fontSize: 10,
    textTransform: 'uppercase',
    fontWeight: '600',
    letterSpacing: 1,
  },
  deviceName: {
    fontSize: 14,
    fontWeight: '700',
    marginVertical: 4,
    textAlign: 'center',
  },
  specsRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
    gap: 4,
    marginVertical: 6,
  },
  specBadge: {
    fontSize: 10,
    paddingHorizontal: 6,
    paddingVertical: 3,
    borderRadius: 10,
    borderWidth: 1,
  },
  pricingContainer: {
    width: '100%',
    marginTop: 8,
    paddingTop: 8,
    borderTopWidth: 1,
  },
  priceRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 4,
  },
  priceLabel: {
    fontSize: 11,
  },
  priceFull: {
    fontSize: 14,
    fontWeight: '700',
  },
  monthlyContainer: {
    borderRadius: 8,
    padding: 6,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginVertical: 4,
  },
  priceMonthly: {
    fontSize: 13,
    fontWeight: '700',
  },
  perMonth: {
    fontSize: 10,
    fontWeight: '400',
    opacity: 0.8,
  },
  financingNote: {
    fontSize: 9,
    textAlign: 'center',
    marginTop: 4,
  },
  selectedBadge: {
    position: 'absolute',
    top: 10,
    right: 10,
    backgroundColor: '#10b981',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  selectedBadgeText: {
    color: 'white',
    fontSize: 10,
    fontWeight: 'bold',
  },
  outOfStockBadge: {
    position: 'absolute',
    top: 10,
    right: 10,
    backgroundColor: '#ef4444',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
  },
  outOfStockText: {
    color: 'white',
    fontSize: 10,
    fontWeight: 'bold',
  },
  confirmContainer: {
      marginTop: 20,
      alignItems: 'center',
  },
  confirmButton: {
      paddingVertical: 12,
      paddingHorizontal: 24,
      borderRadius: 12,
  },
  confirmButtonText: {
      color: 'white',
      fontWeight: '600',
      fontSize: 16,
  },
  actionsContainer: {
      flexDirection: 'row',
      justifyContent: 'center',
      gap: 10,
      marginTop: 20,
      paddingTop: 10,
      borderTopWidth: 1,
  },
  actionButton: {
      borderRadius: 12,
      overflow: 'hidden'
  },
  actionButtonGradient: {
      paddingVertical: 10,
      paddingHorizontal: 20,
      flexDirection: 'row',
      alignItems: 'center'
  },
  actionButtonText: {
      fontWeight: '600'
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
