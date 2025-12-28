import React, { useEffect, useState } from 'react';
import { Layout } from '../../components/Layout';
import { StatCard } from '../../components/StatCard';
import { getAllUsers, updateUserRole } from '../../services/dataService';
import { User, UserRole } from '../../types';
import { Users, Shield, Award, Settings, Search } from 'lucide-react';

export const AdminDashboard: React.FC = () => {
    const [users, setUsers] = useState<User[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');

    useEffect(() => {
        loadUsers();
    }, []);

    const loadUsers = async () => {
        setLoading(true);
        const data = await getAllUsers();
        setUsers(data);
        setLoading(false);
    };

    const handleRoleChange = async (userId: number, newRole: string) => {
        await updateUserRole(userId, newRole as UserRole);
        // Optimistic update or reload
        setUsers(prev => prev.map(u => u.id === userId ? { ...u, role: newRole as UserRole } : u));
    };

    const filteredUsers = users.filter(u => 
        u.email.toLowerCase().includes(searchTerm.toLowerCase()) || 
        u.last_name.toLowerCase().includes(searchTerm.toLowerCase())
    );

    // Stats
    const totalUsers = users.length;
    const experts = users.filter(u => u.role === UserRole.EXPERT).length;
    const moderators = users.filter(u => u.role === UserRole.MODERATOR).length;

    return (
        <Layout>
            <div className="mb-8">
                <h1 className="text-2xl font-bold text-[#053F5C]">Administration Système</h1>
                <p className="text-gray-500">Gérez les rôles et les permissions de la plateforme.</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                <StatCard title="Total Utilisateurs" value={totalUsers} icon={Users} />
                <StatCard title="Experts Actifs" value={experts} icon={Award} color="text-[#F7AD19]" />
                <StatCard title="Modérateurs" value={moderators} icon={Shield} color="text-[#429EBD]" />
            </div>

            <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                <div className="px-6 py-4 border-b border-gray-100 flex flex-col md:flex-row justify-between md:items-center gap-4">
                    <h2 className="text-lg font-bold text-[#053F5C] flex items-center gap-2">
                        <Settings size={20} /> Gestion des Rôles
                    </h2>
                    <div className="relative">
                        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={16} />
                        <input 
                            type="text" 
                            placeholder="Rechercher un utilisateur..." 
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                            className="pl-10 pr-4 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#429EBD]"
                        />
                    </div>
                </div>

                <div className="overflow-x-auto">
                    <table className="w-full text-left">
                        <thead className="bg-gray-50 text-gray-500 text-xs uppercase font-semibold">
                            <tr>
                                <th className="px-6 py-3">Utilisateur</th>
                                <th className="px-6 py-3">Email</th>
                                <th className="px-6 py-3">Rôle Actuel</th>
                                <th className="px-6 py-3">Action</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-100">
                            {loading ? (
                                <tr><td colSpan={4} className="p-8 text-center text-gray-400">Chargement...</td></tr>
                            ) : filteredUsers.map((user) => (
                                <tr key={user.id} className="hover:bg-gray-50">
                                    <td className="px-6 py-4">
                                        <div className="font-medium text-[#053F5C]">{user.first_name} {user.last_name}</div>
                                    </td>
                                    <td className="px-6 py-4 text-sm text-gray-600">{user.email}</td>
                                    <td className="px-6 py-4">
                                        <span className={`px-2 py-1 rounded-full text-xs font-bold uppercase tracking-wide
                                            ${user.role === UserRole.ADMIN ? 'bg-purple-100 text-purple-700' :
                                              user.role === UserRole.EXPERT ? 'bg-yellow-100 text-yellow-700' :
                                              user.role === UserRole.MODERATOR ? 'bg-blue-100 text-blue-700' :
                                              'bg-gray-100 text-gray-600'
                                            }`}>
                                            {user.role}
                                        </span>
                                    </td>
                                    <td className="px-6 py-4">
                                        <select 
                                            value={user.role} 
                                            onChange={(e) => handleRoleChange(user.id, e.target.value)}
                                            className="text-sm border-gray-300 rounded-md shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50 p-1 border"
                                        >
                                            <option value={UserRole.USER}>Utilisateur</option>
                                            <option value={UserRole.EXPERT}>Expert</option>
                                            <option value={UserRole.MODERATOR}>Modérateur</option>
                                            <option value={UserRole.ADMIN}>Admin</option>
                                        </select>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>
        </Layout>
    );
};