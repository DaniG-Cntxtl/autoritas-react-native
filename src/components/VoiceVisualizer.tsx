import React, { useEffect, useRef } from 'react';
import { View, StyleSheet, Animated, Easing } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';

interface VoiceVisualizerProps {
  isActive: boolean;
}

export const VoiceVisualizer: React.FC<VoiceVisualizerProps> = ({ isActive }) => {
  const scaleAnim = useRef(new Animated.Value(1)).current;
  const ripple1 = useRef(new Animated.Value(0)).current;
  const ripple2 = useRef(new Animated.Value(0)).current;
  const ripple3 = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    if (isActive) {
      // Pulse the main orb
      Animated.loop(
        Animated.sequence([
          Animated.timing(scaleAnim, {
            toValue: 1.1,
            duration: 1000,
            easing: Easing.inOut(Easing.ease),
            useNativeDriver: true,
          }),
          Animated.timing(scaleAnim, {
            toValue: 1,
            duration: 1000,
            easing: Easing.inOut(Easing.ease),
            useNativeDriver: true,
          }),
        ])
      ).start();

      // Ripples
      const createRippleAnimation = (anim: Animated.Value, delay: number) => {
        return Animated.loop(
          Animated.sequence([
            Animated.delay(delay),
            Animated.parallel([
              Animated.timing(anim, {
                toValue: 1,
                duration: 2000,
                easing: Easing.out(Easing.ease),
                useNativeDriver: true,
              }),
              Animated.timing(anim, {
                toValue: 0, // Reset opacity/scale implicitly via interpolation
                duration: 0,
                useNativeDriver: true,
              })
            ])
          ])
        );
      };

      // Stagger ripples
      Animated.stagger(600, [
        Animated.loop(
            Animated.timing(ripple1, {
                toValue: 1,
                duration: 2000,
                easing: Easing.out(Easing.quad),
                useNativeDriver: true,
            })
        ),
        Animated.loop(
            Animated.timing(ripple2, {
                toValue: 1,
                duration: 2000,
                delay: 600,
                easing: Easing.out(Easing.quad),
                useNativeDriver: true,
            })
        ),
        Animated.loop(
             Animated.timing(ripple3, {
                 toValue: 1,
                 duration: 2000,
                 delay: 1200,
                 easing: Easing.out(Easing.quad),
                 useNativeDriver: true,
             })
         ),
      ]).start();
      
    } else {
      scaleAnim.setValue(1);
      ripple1.setValue(0);
      ripple2.setValue(0);
      ripple3.setValue(0);
    }
  }, [isActive]);

  const getRippleStyle = (anim: Animated.Value) => ({
    transform: [
      {
        scale: anim.interpolate({
          inputRange: [0, 1],
          outputRange: [1, 3],
        }),
      },
    ],
    opacity: anim.interpolate({
      inputRange: [0, 1],
      outputRange: [0.4, 0],
    }),
  });

  return (
    <View style={styles.container}>
      {/* Ripples */}
      <Animated.View style={[styles.ripple, getRippleStyle(ripple1)]} />
      <Animated.View style={[styles.ripple, getRippleStyle(ripple2)]} />
      <Animated.View style={[styles.ripple, getRippleStyle(ripple3)]} />

      {/* Main Orb */}
      <Animated.View style={[styles.orbContainer, { transform: [{ scale: scaleAnim }] }]}>
        <LinearGradient
          colors={['#137fec', '#2563eb']}
          style={styles.gradient}
        >
          <Ionicons name="mic" size={48} color="white" />
        </LinearGradient>
      </Animated.View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
    width: 200,
    height: 200,
  },
  orbContainer: {
    width: 100,
    height: 100,
    borderRadius: 50,
    elevation: 10,
    shadowColor: '#137fec',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.5,
    shadowRadius: 12,
    zIndex: 10,
  },
  gradient: {
    flex: 1,
    borderRadius: 50,
    alignItems: 'center',
    justifyContent: 'center',
  },
  ripple: {
    position: 'absolute',
    width: 100,
    height: 100,
    borderRadius: 50,
    borderColor: 'rgba(19, 127, 236, 0.3)',
    borderWidth: 2,
    backgroundColor: 'rgba(19, 127, 236, 0.1)',
  },
});
