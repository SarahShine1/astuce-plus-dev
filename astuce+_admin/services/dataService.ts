import { Astuce, AstuceStatus, Report, User, UserRole, Comment, EvaluationData, EvaluationCriteria } from '../types';

// Mock Astuces Data
const MOCK_ASTUCES: Astuce[] = [
  {
    id: 101,
    title: "Optimisation des requêtes Django ORM",
    description: "Utilisation de select_related et prefetch_related pour réduire le N+1 problem.",
    author: "dev_junior_99",
    category: "Développement Backend",
    created_at: "2023-10-25",
    status: AstuceStatus.ASSIGNED,
    assigned_to: 1,
    content_url: "https://picsum.photos/800/400"
  },
  {
    id: 102,
    title: "Culture hors-sol de tomates en milieu urbain",
    description: "Technique d'hydroponie passive utilisant des matériaux recyclés.",
    author: "green_thumb",
    category: "Jardinage",
    created_at: "2023-10-26",
    status: AstuceStatus.ASSIGNED,
    assigned_to: 1
  },
  {
    id: 103,
    title: "Réduire sa facture d'électricité de 20%",
    description: "Analyse des heures creuses et isolation des fenêtres.",
    author: "eco_saver",
    category: "Économie",
    created_at: "2023-10-20",
    status: AstuceStatus.VALIDATED,
    assigned_to: 1
  },
  {
    id: 104,
    title: "Sécuriser une API REST avec JWT",
    description: "Tutoriel complet sur l'implémentation de Simple JWT.",
    author: "cyber_sec",
    category: "Sécurité",
    created_at: "2023-09-15",
    status: AstuceStatus.REJECTED,
    assigned_to: 1
  }
];

let MOCK_REPORTS: Report[] = [
  { id: 1, reported_user: "spam_bot_2000", reason: "Spam massif en commentaires", severity: "high", status: "open", created_at: "2023-10-27" },
  { id: 2, reported_user: "angry_user", reason: "Insultes", severity: "medium", status: "open", created_at: "2023-10-26" },
  { id: 3, reported_user: "fake_news", reason: "Désinformation", severity: "low", status: "resolved", created_at: "2023-10-20" },
];

const MOCK_ALL_USERS: User[] = [
    { id: 1, email: 'expert@astuce.com', first_name: 'Jean', last_name: 'Expert', role: UserRole.EXPERT, avatar: 'https://picsum.photos/id/1005/200/200' },
    { id: 2, email: 'mod@astuce.com', first_name: 'Sarah', last_name: 'Modo', role: UserRole.MODERATOR, avatar: 'https://picsum.photos/id/1011/200/200' },
    { id: 3, email: 'admin@astuce.com', first_name: 'Pierre', last_name: 'Admin', role: UserRole.ADMIN, avatar: 'https://picsum.photos/id/1025/200/200' },
    { id: 4, email: 'user1@gmail.com', first_name: 'Alice', last_name: 'Dupont', role: UserRole.USER },
    { id: 5, email: 'dev_junior@yahoo.fr', first_name: 'Bob', last_name: 'Martin', role: UserRole.USER },
    { id: 6, email: 'spammer@evil.com', first_name: 'Bad', last_name: 'Guy', role: UserRole.USER },
];

let MOCK_COMMENTS: Comment[] = [
    { id: 1, author: 'troll_user', content: 'C est n importe quoi cette astuce !', astuce_id: 103, astuce_title: "Réduire sa facture...", posted_at: '2023-10-28', is_flagged: true },
    { id: 2, author: 'spammer_v2', content: 'Gagnez 5000€ ici: http://scam.link', astuce_id: 101, astuce_title: "Optimisation Django", posted_at: '2023-10-29', is_flagged: true },
    { id: 3, author: 'curious_george', content: 'Merci pour l info, très utile.', astuce_id: 102, astuce_title: "Culture tomates", posted_at: '2023-10-27', is_flagged: false },
    { id: 4, author: 'new_user_1', content: 'Est-ce que ça marche aussi avec Python 3.8 ?', astuce_id: 101, astuce_title: "Optimisation Django", posted_at: '2023-10-30', is_flagged: false },
];

// In-memory storage for evaluations to allow "Detail View" to work
const MOCK_EVALUATIONS: EvaluationData[] = [
    // Pre-fill one for the existing validated astuce
    {
        astuceId: 103,
        expertId: 1,
        totalScore: 85,
        decision: 'validated',
        date: '2023-10-21',
        criteria: {
            methodologie: 9, reproductibilite: 9, standards: 8,
            cas_usage: 9, roi: 7, scalabilite: 6,
            risques: 7, mitigations: 6, conformite: 5,
            valeur_ajoutee: 7, originalite: 6,
            clarte: 4, completude: 2
        }
    }
];

export const getAssignedAstuces = async (expertId: number): Promise<Astuce[]> => {
  await new Promise(resolve => setTimeout(resolve, 500));
  return MOCK_ASTUCES.filter(a => a.assigned_to === expertId && a.status === AstuceStatus.ASSIGNED);
};

export const getExpertHistory = async (expertId: number): Promise<Astuce[]> => {
    await new Promise(resolve => setTimeout(resolve, 500));
    return MOCK_ASTUCES.filter(a => a.assigned_to === expertId && a.status !== AstuceStatus.ASSIGNED);
};

export const getAstuceDetails = async (id: number): Promise<Astuce | undefined> => {
  await new Promise(resolve => setTimeout(resolve, 500));
  return MOCK_ASTUCES.find(a => a.id === id);
};

export const getEvaluationDetails = async (astuceId: number): Promise<EvaluationData | undefined> => {
    await new Promise(resolve => setTimeout(resolve, 400));
    return MOCK_EVALUATIONS.find(e => e.astuceId === astuceId);
}

export const submitEvaluation = async (astuceId: number, score: number, criteria: EvaluationCriteria, decision: string) => {
  console.log(`POST /validations/ -> ID: ${astuceId}, Score: ${score}, Decision: ${decision}`);
  
  // Update Status
  const astuce = MOCK_ASTUCES.find(a => a.id === astuceId);
  if (astuce) {
      astuce.status = decision as AstuceStatus;
  }

  // Save Evaluation Mock
  const existingIndex = MOCK_EVALUATIONS.findIndex(e => e.astuceId === astuceId);
  const newEval: EvaluationData = {
      astuceId,
      expertId: 1, // Mock user ID
      totalScore: score,
      decision,
      criteria,
      date: new Date().toISOString()
  };

  if (existingIndex >= 0) {
      MOCK_EVALUATIONS[existingIndex] = newEval;
  } else {
      MOCK_EVALUATIONS.push(newEval);
  }

  return { success: true };
};

export const getReports = async (): Promise<Report[]> => {
  await new Promise(resolve => setTimeout(resolve, 500));
  return MOCK_REPORTS;
};

export const resolveReport = async (id: number): Promise<void> => {
    console.log(`POST /reports/${id}/resolve`);
    const report = MOCK_REPORTS.find(r => r.id === id);
    if (report) report.status = 'resolved';
    return;
};

export const banUser = async (username: string) => {
    console.log(`POST /users/${username}/ban`);
    return { success: true };
};

export const getAllUsers = async (): Promise<User[]> => {
    await new Promise(resolve => setTimeout(resolve, 600));
    return MOCK_ALL_USERS;
};

export const updateUserRole = async (userId: number, newRole: UserRole) => {
    console.log(`PATCH /users/${userId}/ -> role: ${newRole}`);
    const user = MOCK_ALL_USERS.find(u => u.id === userId);
    if (user) user.role = newRole;
    return { success: true };
};

// Comment Management
export const getComments = async (): Promise<Comment[]> => {
    await new Promise(resolve => setTimeout(resolve, 500));
    return MOCK_COMMENTS;
}

export const deleteComment = async (commentId: number) => {
    console.log(`DELETE /comments/${commentId}`);
    MOCK_COMMENTS = MOCK_COMMENTS.filter(c => c.id !== commentId);
    return { success: true };
}