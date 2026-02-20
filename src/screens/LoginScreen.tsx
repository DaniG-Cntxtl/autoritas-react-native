import React, { useState } from 'react';
import { View, Text, StyleSheet, ImageBackground, TouchableOpacity, ActivityIndicator } from 'react-native';
import { Image } from 'expo-image';
import { LinearGradient } from 'expo-linear-gradient';

// Import local assets (require for RN packager)
const backgroundImage = require('../../assets/background.png');
const logoImage = require('../../assets/contextualLogo.png');
const googleIcon = require('../../assets/google.png');

interface LoginScreenProps {
  onLoginSuccess: () => void;
}

export const LoginScreen: React.FC<LoginScreenProps> = React.memo(({ onLoginSuccess }) => {
  const [isLoading, setIsLoading] = useState(false);

  const handleSignIn = async () => {
    setIsLoading(true);
    // Simulate API call / Firebase Auth
    setTimeout(() => {
      setIsLoading(false);
      onLoginSuccess();
    }, 1500);
  };

  return (
    <ImageBackground
      source={backgroundImage}
      style={styles.background}
      resizeMode="cover"
    >
      <LinearGradient
        colors={['rgba(0,0,0,0.3)', 'rgba(0,0,0,0.7)']}
        style={styles.overlay}
      >
        <View style={styles.content}>
          <Image 
            source={logoImage} 
            style={styles.logo} 
            contentFit="contain"
            transition={300}
          />
          
          <Text style={styles.title}>Talk with your data</Text>
          
          <TouchableOpacity 
            onPress={handleSignIn}
            disabled={isLoading}
            style={styles.buttonContainer}
            activeOpacity={0.8}
          >
            <View style={styles.button}>
              <View style={styles.iconContainer}>
                {isLoading ? (
                  <ActivityIndicator size="small" color="#000" />
                ) : (
                  <Image source={googleIcon} style={styles.googleIcon} contentFit="contain" />
                )}
              </View>
              <Text style={styles.buttonText}>Sign in with Google</Text>
            </View>
          </TouchableOpacity>
        </View>
      </LinearGradient>
    </ImageBackground>
  );
});

const styles = StyleSheet.create({
  background: {
    flex: 1,
    width: '100%',
    height: '100%',
  },
  overlay: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  content: {
    width: '100%',
    maxWidth: 400,
    padding: 32,
    alignItems: 'center',
  },
  logo: {
    width: 280,
    height: 80, // Adjust based on actual aspect ratio
    marginBottom: 20,
  },
  title: {
    fontSize: 32,
    fontWeight: '400', // Sancoale font weight simulation
    color: '#fff',
    textAlign: 'center',
    marginBottom: 48,
    // fontFamily: 'Sancoale', // Custom font if loaded
  },
  buttonContainer: {
    width: '100%',
    maxWidth: 280,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 4.65,
    elevation: 8,
  },
  button: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#ff4d4d', // nagareRed approx
    borderRadius: 8,
    paddingVertical: 12,
    paddingHorizontal: 16,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.2)',
  },
  iconContainer: {
    backgroundColor: '#fff',
    borderRadius: 12, // Circle or rounded square
    padding: 6,
    marginRight: 12,
    width: 32,
    height: 32,
    justifyContent: 'center',
    alignItems: 'center',
  },
  googleIcon: {
    width: 18,
    height: 18,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});
