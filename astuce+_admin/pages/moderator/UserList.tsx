import React, { useEffect, useState } from 'react';
import { Layout } from '../../components/Layout';
import { getAllUsers, banUser } from '../../services/dataService';
import { User, UserRole } from '../../types';
import { Users, Ban, CheckCircle, Search } from 'lucide-react';

export const UserList: React.FC = () => {
    const [users, setUsers] = useState<User[]>([]);
    const [searchTerm, setSearchTerm] = useState('');

    useEffect(() => {
        getAllUsers().then(setUsers);
    }, []);

    const handleBan = async (user: User) => {
        if(window.confirm(`Voulez-vous bannir ${user.email} de la plateforme ?`)) {
            await banUser(user.email);
            // In a real app, update state to reflect ban status
            alert("Utilisateur banni (simulation)");
        }
    };

    const filteredUsers = users.filter(u => 
        (u.first_name + ' ' + u.last_name).toLowerCase().includes(searchTerm.toLowerCase()) ||
        u.email.toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <Layout>
            <div className="mb-6 flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-[#053F5C]">Gestion des Utilisateurs</h1>
                    <p className="text-gray-500">Consultez et modérez la base utilisateur.</p>
                </div>
                <div className="relative">
                     <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={18} />
                     <input 
                        type="text" 
                        placeholder="Rechercher..." 
                        value={searchTerm}
                        onChange={e => setSearchTerm(e.target.value)}
                        className="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#429EBD] outline-none"
                     />
                </div>
            </div>

            <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                <table className="w-full text-left">
                    <thead className="bg-gray-50 text-gray-500 text-xs uppercase font-semibold">
                        <tr>
                            <th className="px-6 py-3">Utilisateur</th>
                            <th className="px-6 py-3">Email</th>
                            <th className="px-6 py-3">Statut</th>
                            <th className="px-6 py-3 text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100">
                        {filteredUsers.map((user) => (
                            <tr key={user.id} className="hover:bg-gray-50">
                                <td className="px-6 py-4 flex items-center gap-3">
                                    <div className="w-8 h-8 rounded-full bg-gray-200 flex items-center justify-center text-gray-600 font-bold">
                                        {user.first_name[0]}
                                    </div>
                                    <span className="font-medium text-[#053F5C]">{user.first_name} {user.last_name}</span>
                                </td>
                                <td className="px-6 py-4 text-gray-600">{user.email}</td>
                                <td className="px-6 py-4">
                                    {/* Mock status since User type doesn't have it yet, assuming Active for demo */}
                                    <span className="inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-700">
                                        <CheckCircle size={12} /> Actif
                                    </span>
                                </td>
                                <td className="px-6 py-4 text-right">
                                    {user.role === UserRole.USER && (
                                        <button 
                                            onClick={() => handleBan(user)}
                                            className="inline-flex items-center gap-1 px-3 py-1.5 bg-red-50 text-red-600 hover:bg-red-100 rounded text-xs font-bold transition-colors"
                                        >
                                            <Ban size={14} /> BANNIR
                                        </button>
                                    )}
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </Layout>
    );
};