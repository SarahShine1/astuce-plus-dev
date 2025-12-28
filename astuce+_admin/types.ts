export enum UserRole {
  ADMIN = 'admin',
  MODERATOR = 'moderateur',
  EXPERT = 'expert',
  USER = 'utilisateur'
}

export interface User {
  id: number;
  email: string;
  first_name: string;
  last_name: string;
  role: UserRole;
  avatar?: string;
}

export interface AuthResponse {
  access: string;
  refresh: string;
  user: User;
}

// Astuce Workflow
export enum AstuceStatus {
  PENDING = 'pending',
  ASSIGNED = 'assigned',
  VALIDATED = 'validated',
  CHANGES_REQUESTED = 'changes_requested',
  REJECTED = 'rejected'
}

export interface Astuce {
  id: number;
  title: string;
  description: string;
  content_url?: string; // Image or Video
  author: string;
  created_at: string;
  status: AstuceStatus;
  category: string;
  assigned_to?: number; // Expert ID
}

// Evaluation Grid
export interface EvaluationCriteria {
  // Scientific (30)
  methodologie: number; // /10
  reproductibilite: number; // /10
  standards: number; // /10
  
  // Applicability (25)
  cas_usage: number; // /10
  roi: number; // /8
  scalabilite: number; // /7

  // Security (20)
  risques: number; // /8
  mitigations: number; // /7
  conformite: number; // /5

  // Innovation (15)
  valeur_ajoutee: number; // /8
  originalite: number; // /7

  // Documentation (10)
  clarte: number; // /5
  completude: number; // /5
}

export interface EvaluationData {
  astuceId: number;
  criteria: EvaluationCriteria;
  totalScore: number;
  decision: string;
  expertId: number;
  date: string;
}

export interface Report {
  id: number;
  reported_user: string;
  reason: string;
  severity: 'low' | 'medium' | 'high';
  status: 'open' | 'resolved';
  created_at: string;
}

export interface Comment {
  id: number;
  author: string;
  content: string;
  astuce_id: number;
  astuce_title: string;
  posted_at: string;
  is_flagged: boolean;
}