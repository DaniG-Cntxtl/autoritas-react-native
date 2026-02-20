import { GeneratedTheme } from '../context/ThemeEngine';

export const STITCH_THEME: GeneratedTheme = {
  meta: { name: 'Stitch Remix', generated_at: Date.now() },
  styles: {
    colors: {
      primary: '#137fec',
      background: '#ffffff',
      text: '#111827', // gray-900
      secondaryText: '#9ca3af', // gray-400
      accent: '#f3f4f6', // gray-100
      cardBackground: '#ffffff',
      inputBackground: '#f9fafb', // gray-50
      messageBubbleUser: '#137fec',
      messageBubbleAgent: '#f3f4f6',
    },
    layout: {
      borderRadius: 4, // "Geometric" look often implies smaller radius or sharp corners
      borderWidth: 1,
      spacingUnit: 8,
      chatPosition: 'bottom',
      widgetPosition: 'top',
      containerFlexDirection: 'column',
    },
    typography: {
      headingFontName: 'Inter', // Assuming Inter is available or fallback to system
      headingFontUrl: '',
      bodyFontName: 'Inter',
      bodyFontUrl: '',
    },
  },
  assets: {
    // Optional: Add gradient definitions here if the ThemeEngine supports it
  },
};

export const STITCH_THEME_DARK: GeneratedTheme = {
  meta: { name: 'Stitch Remix Dark', generated_at: Date.now() },
  styles: {
    colors: {
      primary: '#137fec',
      background: '#101922',
      text: '#FFFFFF',
      secondaryText: '#92adc9',
      accent: '#192633',
      cardBackground: '#192633',
      inputBackground: 'rgba(255, 255, 255, 0.05)',
      messageBubbleUser: '#137fec',
      messageBubbleAgent: '#1e293b', // slate-800
    },
    layout: {
      borderRadius: 4,
      borderWidth: 1,
      spacingUnit: 8,
      chatPosition: 'bottom',
      widgetPosition: 'top',
      containerFlexDirection: 'column',
    },
    typography: {
      headingFontName: 'Inter',
      headingFontUrl: '',
      bodyFontName: 'Inter',
      bodyFontUrl: '',
    },
  },
  assets: {},
};
