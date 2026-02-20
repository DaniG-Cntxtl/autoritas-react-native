import React from 'react';
import { View, StyleSheet, ViewProps } from 'react-native';

interface Props extends ViewProps {
  intensity?: number;
  tint?: 'light' | 'dark' | 'default' | 'systemChromeMaterial' | 'systemMaterial' | 'systemThickMaterial' | 'systemThinMaterial' | 'systemUltraThinMaterial' | 'systemChromeMaterialDark' | 'systemMaterialDark' | 'systemThickMaterialDark' | 'systemThinMaterialDark' | 'systemUltraThinMaterialDark' | 'systemChromeMaterialLight' | 'systemMaterialLight' | 'systemThickMaterialLight' | 'systemThinMaterialLight' | 'systemUltraThinMaterialLight';
  children?: React.ReactNode;
}

export const CrossPlatformBlur: React.FC<Props> = ({ style, intensity, tint = 'default', children, ...props }) => {
  // Map "tint" to background color opacity/shade
  const isDark = tint.includes('dark') || tint === 'dark';
  
  const backgroundColor = isDark 
    ? 'rgba(30, 30, 30, 0.85)' 
    : 'rgba(255, 255, 255, 0.75)';

  return (
    <View style={[style, styles.container, { 
      backgroundColor,
      borderColor: isDark ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.05)',
    }]} {...props}>
      {children}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    // @ts-ignore - React Native Web specific style
    backdropFilter: 'blur(15px)',
    WebkitBackdropFilter: 'blur(15px)',
    borderWidth: 1,
  }
});
