export interface LiveKitAuthResponse {
  token: string;
  url: string;
}

export const fetchLiveKitToken = async (roomName: string, participantName: string): Promise<LiveKitAuthResponse> => {
  const API_URL = 'https://agent.artemisa-hb.cloud/livekit/token';
  
  try {
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        room_name: roomName,
        participant_name: participantName,
      }),
    });

    if (!response.ok) {
      throw new Error(`Failed to fetch token: ${response.statusText}`);
    }

    const data = await response.json();
    
    let finalUrl = data.url || 'wss://agent.artemisa-hb.cloud';
    
    // iOS and Android require secure connections (ATS/Cleartext rules)
    // Upgrade ws:// to wss:// for remote servers
    if (finalUrl.startsWith('ws://') && !finalUrl.includes('localhost') && !finalUrl.includes('127.0.0.1')) {
      finalUrl = finalUrl.replace('ws://', 'wss://');
    }
    
    // Support both {token, url} and the previous plain string/token object formats for robustness
    return {
      token: data.token || data,
      url: finalUrl
    };
  } catch (error) {
    console.error('[AuthService] Error fetching token:', error);
    throw error;
  }
};