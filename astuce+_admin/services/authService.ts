import { AuthResponse, User, UserRole } from '../types';

// Mock user database
const MOCK_USERS: Record<string, User> = {
  'expert@astuce.com': {
    id: 1,
    email: 'expert@astuce.com',
    first_name: 'Jean',
    last_name: 'Expert',
    role: UserRole.EXPERT,
    avatar: 'https://picsum.photos/id/1005/200/200'
  },
  'mod@astuce.com': {
    id: 2,
    email: 'mod@astuce.com',
    first_name: 'Sarah',
    last_name: 'Modo',
    role: UserRole.MODERATOR,
    avatar: 'https://picsum.photos/id/1011/200/200'
  },
  'admin@astuce.com': {
    id: 3,
    email: 'admin@astuce.com',
    first_name: 'Pierre',
    last_name: 'Admin',
    role: UserRole.ADMIN,
    avatar: 'https://picsum.photos/id/1025/200/200'
  }
};

export const login = async (email: string, password: string): Promise<AuthResponse> => {
  // Simulate network delay
  await new Promise(resolve => setTimeout(resolve, 800));

  if (MOCK_USERS[email]) {
    return {
      access: 'fake-jwt-access-token',
      refresh: 'fake-jwt-refresh-token',
      user: MOCK_USERS[email]
    };
  }
  
  throw new Error('Identifiants invalides');
};

export const logout = () => {
  localStorage.removeItem('token');
  localStorage.removeItem('user');
};

export const getCurrentUser = (): User | null => {
  const userStr = localStorage.getItem('user');
  return userStr ? JSON.parse(userStr) : null;
};