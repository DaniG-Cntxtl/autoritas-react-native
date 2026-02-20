import React, { createContext, useContext, useState } from 'react';
import * as Font from 'expo-font';

// --- Types ---

export interface ThemeColors {
  primary: string;
  background: string;
  text: string;
  secondaryText: string;
  accent: string;
  cardBackground: string;
  inputBackground: string;
  messageBubbleUser: string;
  messageBubbleAgent: string;
}

export interface ThemeLayout {
  borderRadius: number;
  borderWidth: number;
  spacingUnit: number;
  // New structural properties
  chatPosition: 'bottom' | 'top' | 'overlay' | 'hidden'; 
  widgetPosition: 'top' | 'bottom' | 'stacked';
  containerFlexDirection: 'column' | 'column-reverse' | 'row';
}

export interface ThemeTypography {
  headingFontName: string;
  headingFontUrl: string; 
  bodyFontName: string;
  bodyFontUrl: string;
}

export interface ThemeAssets {
  backgroundUrl?: string; 
  overlayOpacity?: number;
}

export interface GeneratedTheme {
  meta: { name: string; generated_at: number };
  styles: {
    colors: ThemeColors;
    layout: ThemeLayout;
    typography: ThemeTypography;
  };
  assets: ThemeAssets;
}

// Default "Loading" or "Base" Theme
const DEFAULT_THEME: GeneratedTheme = {
  meta: { name: 'Default System', generated_at: 0 },
  styles: {
    colors: {
      primary: '#007AFF',
      background: '#FFFFFF',
      text: '#000000',
      secondaryText: '#666666',
      accent: '#E5E5EA',
      cardBackground: '#F2F2F7',
      inputBackground: '#F0F0F0',
      messageBubbleUser: '#007AFF',
      messageBubbleAgent: '#E5E5EA',
    },
    layout: {
      borderRadius: 12,
      borderWidth: 0,
      spacingUnit: 8,
      chatPosition: 'bottom',
      widgetPosition: 'top',
      containerFlexDirection: 'column',
    },
    typography: {
      headingFontName: 'System',
      headingFontUrl: '',
      bodyFontName: 'System',
      bodyFontUrl: '',
    },
  },
  assets: {},
};

interface ThemeContextType {
  theme: GeneratedTheme;
  applyTheme: (themePayload: GeneratedTheme) => Promise<void>;
  isLoading: boolean;
}

const ThemeContext = createContext<ThemeContextType>({
  theme: DEFAULT_THEME,
  applyTheme: async () => {},
  isLoading: false,
});

export const useTheme = () => useContext(ThemeContext);

export const ThemeEngineProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [theme, setTheme] = useState<GeneratedTheme>(DEFAULT_THEME);
  const [isLoading, setIsLoading] = useState(false);

  const applyTheme = async (newTheme: GeneratedTheme) => {
    setIsLoading(true);
    try {
      const fontsToLoad: Record<string, string> = {};
      const { typography } = newTheme.styles;

      if (typography.headingFontUrl && typography.headingFontName !== 'System') {
        fontsToLoad[typography.headingFontName] = typography.headingFontUrl;
      }
      if (typography.bodyFontUrl && typography.bodyFontName !== 'System') {
        fontsToLoad[typography.bodyFontName] = typography.bodyFontUrl;
      }

      if (Object.keys(fontsToLoad).length > 0) {
        await Font.loadAsync(fontsToLoad);
      }
      
      // Merge with default to ensure new structural props exist if missing in JSON
      const mergedTheme = {
        ...DEFAULT_THEME,
        ...newTheme,
        styles: {
          ...DEFAULT_THEME.styles,
          ...newTheme.styles,
          layout: {
             ...DEFAULT_THEME.styles.layout,
             ...newTheme.styles.layout
          },
          colors: {
             ...DEFAULT_THEME.styles.colors,
             ...newTheme.styles.colors
          }
        }
      };

      setTheme(mergedTheme);
    } catch (error) {
      console.error("Failed to apply theme:", error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <ThemeContext.Provider value={{ theme, applyTheme, isLoading }}>
      {children}
    </ThemeContext.Provider>
  );
};