import { GeneratedTheme } from './context/ThemeEngine';

export const THEME_MEDIEVAL: any = {
  meta: { name: 'Royal Scroll', generated_at: 123 },
  styles: {
    colors: {
      primary: '#8B4513', // SaddleBrown
      background: '#F5DEB3', // Wheat
      text: '#2F1B0C', // Very dark brown
      accent: '#CD853F', // Peru
      cardBackground: '#FAEBD7', // AntiqueWhite
    },
    layout: {
      borderRadius: 2, // Almost sharp, handmade look
      borderWidth: 2,
      spacingUnit: 12,
    },
    typography: {
      // In a real app, these would be valid TTF URLs. 
      // For POC, we might need to rely on system fonts or pre-loaded assets if we don't have internet.
      // Assuming 'serif' for now as fallback if load fails.
      headingFontName: 'System', 
      headingFontUrl: '', 
      bodyFontName: 'System', 
      bodyFontUrl: '',
    },
  },
  assets: {
    backgroundUrl: 'https://img.freepik.com/free-photo/old-paper-texture_1194-6663.jpg', // Placeholder
  },
};

export const THEME_CYBER: any = {
  meta: { name: 'Neon Protocol', generated_at: 124 },
  styles: {
    colors: {
      primary: '#00FF00', // Lime
      background: '#000000', // Black
      text: '#00FF00', // Green text
      accent: '#FF00FF', // Magenta
      cardBackground: '#111111',
    },
    layout: {
      borderRadius: 0, // Sharp angles
      borderWidth: 1,
      spacingUnit: 8,
    },
    typography: {
      headingFontName: 'System', // 'Courier New' style
      headingFontUrl: '',
      bodyFontName: 'System',
      bodyFontUrl: '',
    },
  },
  assets: {
    // Hexagon grid pattern
    backgroundUrl: 'https://img.freepik.com/free-vector/dark-hexagonal-background-with-gradient-color_79603-1409.jpg',
  },
};

export const THEME_FRUTIGER: any = {
  meta: { name: 'Aero Bliss', generated_at: 125 },
  styles: {
    colors: {
      primary: '#00A8E8', // Cyan
      background: '#FFFFFF',
      text: '#333333',
      accent: '#8FD6E8',
      cardBackground: 'rgba(255,255,255,0.8)', // Glassmorphism-ready
    },
    layout: {
      borderRadius: 25, // Very round
      borderWidth: 0,
      spacingUnit: 10,
    },
    typography: {
      headingFontName: 'System', 
      headingFontUrl: '',
      bodyFontName: 'System',
      bodyFontUrl: '',
    },
  },
  assets: {
    backgroundUrl: 'https://img.freepik.com/free-vector/gradient-spring-background_23-2148449015.jpg', // Greenish bokeh
  },
};
