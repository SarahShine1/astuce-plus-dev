import React, { useEffect, useState } from 'react';
import { Layout } from '../../components/Layout';
import { getExpertHistory } from '../../services/dataService';
import { getCurrentUser } from '../../services/authService';
import { Astuce, AstuceStatus } from '../../types';
import { FileCheck, Calendar, ArrowUpRight } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

export const EvaluationHistory: React.FC = () => {
    const [history, setHistory] = useState<Astuce[]>([]);
    const [loading, setLoading] = useState(true);
    const user = getCurrentUser();
    const navigate = useNavigate();

    useEffect(() => {
        if(user) {
            getExpertHistory(user.id).then(data => {
                setHistory(data);
                setLoading(false);
            });
        }
    }, [user]);

    const getStatusBadge = (status: AstuceStatus) => {
        switch(status) {
            case AstuceStatus.VALIDATED:
                return <span className="bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs font-bold">VALIDÉE</span>;
            case AstuceStatus.CHANGES_REQUESTED:
                return <span className="bg-yellow-100 text-yellow-800 px-2 py-1 rounded-full text-xs font-bold">MODIFS DEMANDÉES</span>;
            case AstuceStatus.REJECTED:
                return <span className="bg-red-100 text-red-800 px-2 py-1 rounded-full text-xs font-bold">REJETÉE</span>;
            default:
                return <span>{status}</span>;
        }
    };

    return (
        <Layout>
            <div className="mb-8">
                <h1 className="text-2xl font-bold text-[#053F5C]">Mes Évaluations Passées</h1>
                <p className="text-gray-500">Historique complet de vos décisions.</p>
            </div>

            <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                <div className="p-6 border-b border-gray-100 flex items-center gap-2 text-[#053F5C] font-bold">
                    <FileCheck size={20} /> Historique
                </div>

                {loading ? (
                    <div className="p-8 text-center text-gray-400">Chargement...</div>
                ) : history.length === 0 ? (
                    <div className="p-12 text-center text-gray-500">Aucune évaluation passée trouvée.</div>
                ) : (
                    <table className="w-full text-left">
                        <thead className="bg-gray-50 text-gray-500 text-xs uppercase font-semibold">
                            <tr>
                                <th className="px-6 py-3">Astuce</th>
                                <th className="px-6 py-3">Décision</th>
                                <th className="px-6 py-3">Date de création</th>
                                <th className="px-6 py-3 text-right">Détails</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-100">
                            {history.map((item) => (
                                <tr key={item.id} className="hover:bg-gray-50">
                                    <td className="px-6 py-4">
                                        <div className="font-medium text-[#053F5C]">{item.title}</div>
                                        <div className="text-xs text-gray-400">@{item.author}</div>
                                    </td>
                                    <td className="px-6 py-4">
                                        {getStatusBadge(item.status)}
                                    </td>
                                    <td className="px-6 py-4 text-sm text-gray-500 flex items-center gap-2">
                                        <Calendar size={14} />
                                        {new Date(item.created_at).toLocaleDateString()}
                                    </td>
                                    <td className="px-6 py-4 text-right">
                                        <button 
                                            onClick={() => navigate(`/expert/history/${item.id}`)}
                                            className="text-[#429EBD] hover:text-[#053F5C]"
                                        >
                                            <ArrowUpRight size={18} />
                                        </button>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                )}
            </div>
        </Layout>
    );
};