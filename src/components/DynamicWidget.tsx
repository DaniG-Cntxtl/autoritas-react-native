import React from 'react';
import { View, Text, Image, StyleSheet, TouchableOpacity, ImageBackground } from 'react-native';
import { useTheme } from '../context/ThemeEngine';

interface ProductCardProps {
  title: string;
  price: string;
  imageUrl: string;
}

export const DynamicProductCard: React.FC<ProductCardProps> = ({ title, price, imageUrl }) => {
  const { theme } = useTheme();
  const { colors, layout, typography } = theme.styles;
  const { assets } = theme;

  // Dynamic Styles Calculation
  const containerStyle = {
    backgroundColor: colors.cardBackground,
    borderRadius: layout.borderRadius,
    borderWidth: layout.borderWidth,
    borderColor: colors.text, // Using text color for border if width > 0
    padding: layout.spacingUnit * 2,
    margin: layout.spacingUnit,
    // Add shadow only if border width is small (heuristic)
    shadowColor: "#000",
    shadowOffset: { width: 0, height: layout.borderWidth > 0 ? 0 : 2 },
    shadowOpacity: layout.borderWidth > 0 ? 0 : 0.1,
    shadowRadius: 4,
    elevation: layout.borderWidth > 0 ? 0 : 3,
  };

  const textStyle = {
    color: colors.text,
    fontFamily: typography.bodyFontName,
    marginBottom: layout.spacingUnit,
  };

  const titleStyle = {
    color: colors.primary,
    fontFamily: typography.headingFontName,
    fontSize: 18,
    marginBottom: layout.spacingUnit,
    fontWeight: 'bold' as const, // Fallback
  };

  const buttonStyle = {
    backgroundColor: colors.primary,
    padding: layout.spacingUnit,
    borderRadius: layout.borderRadius / 2, // Slightly sharper than card
    alignItems: 'center' as const,
    marginTop: layout.spacingUnit,
    borderWidth: layout.borderWidth,
    borderColor: colors.accent,
  };

  // Content Renderer
  const content = (
    <>
       <Image 
        source={{ uri: imageUrl }} 
        style={{ 
          width: '100%', 
          height: 150, 
          resizeMode: 'contain',
          marginBottom: layout.spacingUnit 
        }} 
      />
      <Text style={titleStyle}>{title}</Text>
      <Text style={textStyle}>Desde {price}/mes</Text>
      
      <TouchableOpacity style={buttonStyle}>
        <Text style={{ color: colors.background, fontFamily: typography.bodyFontName }}>
          Ver Detalles
        </Text>
      </TouchableOpacity>
    </>
  );

  // If theme has a background texture for the card specifically (not implemented in type yet, but good for future)
  // For now, let's keep it simple.
  
  return (
    <View style={containerStyle}>
      {content}
    </View>
  );
};
