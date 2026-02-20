import React from 'react';
import { BlurView, BlurViewProps } from 'expo-blur';

interface Props extends BlurViewProps {
  children?: React.ReactNode;
}

export const CrossPlatformBlur: React.FC<Props> = ({ style, intensity, tint, children, ...props }) => {
  return (
    <BlurView intensity={intensity} tint={tint} style={style} {...props}>
      {children}
    </BlurView>
  );
};
