import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useTheme } from '../../context/ThemeEngine';
import { MaterialIcons } from '@expo/vector-icons';

export interface MenuOption {
  id: string;
  title: string;
  description: string;
  icon: string;
  color_theme: 'blue' | 'purple' | 'emerald' | 'amber';
}

interface WelcomeMenuProps {
  data: {
    greeting?: string;
    options: MenuOption[];
  };
  onAction: (actionId: string) => void;
}

export const WelcomeMenu: React.FC<WelcomeMenuProps> = ({ data, onAction }) => {
  const { theme } = useTheme();
  const { colors } = theme.styles;

  const getThemeColor = (colorTheme: string) => {
      switch (colorTheme) {
          case 'blue': return '#3b82f6';
          case 'purple': return '#a855f7';
          case 'emerald': return '#10b981';
          case 'amber': return '#f59e0b';
          default: return colors.primary;
      }
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={[styles.greetingText, { color: colors.text }]}>
          {data.greeting || 'Hola,\n¿qué quieres\nhacer hoy?'}
        </Text>
      </View>

      <View style={styles.menuList}>
        {data.options.map((option, index) => {
          const themeColor = getThemeColor(option.color_theme);
          return (
            <TouchableOpacity 
              key={option.id || index}
              style={[styles.menuTile, { backgroundColor: colors.cardBackground, borderLeftColor: themeColor }]}
              onPress={() => onAction(option.id)}
              activeOpacity={0.8}
            >
              <View style={styles.tileContent}>
                <View style={styles.textColumn}>
                  <Text style={[styles.tileCategory, { color: themeColor }]}>{option.color_theme === 'blue' ? 'Support' : option.color_theme === 'purple' ? 'Offers' : option.color_theme === 'emerald' ? 'Finance' : 'Account'}</Text>
                  <Text style={[styles.tileTitle, { color: colors.text }]}>{option.title}</Text>
                  <Text style={[styles.tileDesc, { color: colors.secondaryText }]}>{option.description}</Text>
                </View>
                <MaterialIcons name={option.icon as any} size={28} color={themeColor} style={{ opacity: 0.5 }} />
              </View>
            </TouchableOpacity>
          );
        })}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    width: '100%',
    paddingVertical: 16,
  },
  header: {
    paddingHorizontal: 8,
    marginBottom: 24,
  },
  greetingText: {
    fontSize: 32,
    fontWeight: '900',
    lineHeight: 38,
    letterSpacing: -0.5,
  },
  menuList: {
    gap: 4, // Very tight spacing as per HTML design (mb-1)
  },
  menuTile: {
    width: '100%',
    padding: 24,
    borderLeftWidth: 4,
    borderRadius: 4,
  },
  tileContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
  },
  textColumn: {
    flex: 1,
    paddingRight: 16,
  },
  tileCategory: {
    fontSize: 10,
    fontWeight: '800',
    textTransform: 'uppercase',
    letterSpacing: 1.5,
    marginBottom: 4,
  },
  tileTitle: {
    fontSize: 20,
    fontWeight: '800',
    letterSpacing: -0.5,
  },
  tileDesc: {
    fontSize: 14,
    marginTop: 2,
  },
});
