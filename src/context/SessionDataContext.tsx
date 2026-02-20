import React, { createContext, useContext, useState, useCallback } from 'react';

// Flexible interface for whatever the agent sends
export interface SessionData {
  [key: string]: any;
}

interface SessionContextType {
  data: SessionData;
  updateData: (newData: SessionData) => void;
  clearData: () => void;
}

const SessionContext = createContext<SessionContextType>({
  data: {},
  updateData: () => {},
  clearData: () => {},
});

export const useSessionData = () => useContext(SessionContext);

export const SessionDataProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [data, setData] = useState<SessionData>({});

  const updateData = useCallback((newData: SessionData) => {
    setData(prev => ({ ...prev, ...newData }));
  }, []);

  const clearData = useCallback(() => {
    setData({});
  }, []);

  return (
    <SessionContext.Provider value={{ data, updateData, clearData }}>
      {children}
    </SessionContext.Provider>
  );
};
