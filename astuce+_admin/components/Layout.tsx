import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { 
  LogOut, 
  LayoutDashboard, 
  FileCheck, 
  Users, 
  ShieldAlert, 
  Settings,
  MessageSquare,
  Menu
} from 'lucide-react';
import { UserRole } from '../types';
import { COLORS } from '../constants';
import { logout, getCurrentUser } from '../services/authService';

interface SidebarItemProps {
  icon: React.ElementType;
  label: string;
  path: string;
  isActive: boolean;
  onClick: () => void;
}

const SidebarItem: React.FC<SidebarItemProps> = ({ icon: Icon, label, path, isActive, onClick }) => (
  <button
    onClick={onClick}
    className={`w-full flex items-center gap-3 px-4 py-3 transition-colors duration-200 ${
      isActive 
        ? 'bg-[#429EBD] text-white' 
        : 'text-gray-300 hover:bg-[#04334a] hover:text-white'
    }`}
  >
    <Icon size={20} />
    <span className="font-medium">{label}</span>
  </button>
);

export const Layout: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const navigate = useNavigate();
  const location = useLocation();
  const user = getCurrentUser();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const getMenuItems = () => {
    if (!user) return [];
    
    const items = [];

    // Expert Menu
    if (user.role === UserRole.EXPERT) {
      items.push({ label: 'Dashboard', path: '/expert', icon: LayoutDashboard });
      items.push({ label: 'Mes Évaluations', path: '/expert/history', icon: FileCheck });
    }

    // Moderator Menu
    if (user.role === UserRole.MODERATOR) {
      items.push({ label: 'Dashboard', path: '/moderator', icon: LayoutDashboard });
      items.push({ label: 'Utilisateurs', path: '/moderator/users', icon: Users });
      items.push({ label: 'Commentaires', path: '/moderator/comments', icon: MessageSquare });
      items.push({ label: 'Signalements', path: '/moderator/reports', icon: ShieldAlert });
    }

    // Admin Menu
    if (user.role === UserRole.ADMIN) {
      items.push({ label: 'Administration', path: '/admin', icon: Settings });
    }

    return items;
  };

  return (
    <div className="flex h-screen bg-gray-50 overflow-hidden">
      {/* Sidebar */}
      <aside className="w-64 flex-shrink-0 flex flex-col shadow-xl" style={{ backgroundColor: COLORS.primaryBlue }}>
        <div className="p-6 flex items-center gap-3 border-b border-[#429EBD]/30">
          <div className="w-8 h-8 rounded bg-[#F7AD19] flex items-center justify-center font-bold text-[#053F5C]">
            A+
          </div>
          <h1 className="text-xl font-bold text-white tracking-wide">Astuce<span className="text-[#F7AD19]">+</span></h1>
        </div>

        <div className="p-4">
          <div className="flex items-center gap-3 px-4 py-2 bg-[#04334a] rounded-lg mb-6">
            <img src={user?.avatar} alt="Profile" className="w-8 h-8 rounded-full border border-gray-400" />
            <div className="overflow-hidden">
              <p className="text-sm font-medium text-white truncate">{user?.first_name} {user?.last_name}</p>
              <p className="text-xs text-[#429EBD] uppercase font-bold tracking-wider">{user?.role}</p>
            </div>
          </div>

          <nav className="space-y-1">
            {getMenuItems().map((item) => (
              <SidebarItem
                key={item.path}
                icon={item.icon}
                label={item.label}
                path={item.path}
                isActive={location.pathname === item.path}
                onClick={() => navigate(item.path)}
              />
            ))}
          </nav>
        </div>

        <div className="mt-auto p-4 border-t border-[#429EBD]/30">
          <button
            onClick={handleLogout}
            className="w-full flex items-center gap-3 px-4 py-2 text-gray-300 hover:text-white hover:bg-red-500/20 rounded-lg transition-colors"
          >
            <LogOut size={18} />
            <span>Déconnexion</span>
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 overflow-auto relative">
        <header className="bg-white shadow-sm sticky top-0 z-10 px-8 py-4 flex items-center justify-between md:hidden">
            <div className="flex items-center gap-2">
                <Menu className="text-[#053F5C]" />
                <span className="font-bold text-[#053F5C]">Menu</span>
            </div>
        </header>
        <div className="p-8 max-w-7xl mx-auto">
            {children}
        </div>
      </main>
    </div>
  );
};