import React, { useEffect, useState } from 'react';
import { Layout } from '../../components/Layout';
import { getComments, deleteComment } from '../../services/dataService';
import { Comment } from '../../types';
import { MessageSquare, Trash2, Check, Flag, Filter } from 'lucide-react';

export const CommentList: React.FC = () => {
    const [comments, setComments] = useState<Comment[]>([]);
    const [loading, setLoading] = useState(true);
    // Changed default filter to 'all' as requested
    const [filter, setFilter] = useState<'all' | 'flagged'>('all');

    useEffect(() => {
        loadComments();
    }, []);

    const loadComments = async () => {
        setLoading(true);
        const data = await getComments();
        setComments(data);
        setLoading(false);
    };

    const handleDelete = async (id: number) => {
        if(window.confirm("Confirmer la suppression de ce commentaire ?")) {
            await deleteComment(id);
            setComments(prev => prev.filter(c => c.id !== id));
        }
    };

    const handleApprove = async (id: number) => {
        // In real app, unflag API call
        setComments(prev => prev.map(c => c.id === id ? { ...c, is_flagged: false } : c));
    };

    const filteredComments = filter === 'all' 
        ? comments 
        : comments.filter(c => c.is_flagged);

    return (
        <Layout>
            <div className="mb-6 flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-[#053F5C]">Modération des Commentaires</h1>
                    <p className="text-gray-500">Gérez les interactions utilisateurs et les signalements.</p>
                </div>
                
                <div className="flex bg-white rounded-lg p-1 shadow-sm border border-gray-200">
                    <button 
                        onClick={() => setFilter('all')}
                        className={`px-4 py-2 rounded-md text-sm font-medium transition-all ${filter === 'all' ? 'bg-[#053F5C] text-white shadow-sm' : 'text-gray-500 hover:bg-gray-50'}`}
                    >
                        Tous
                    </button>
                    <button 
                        onClick={() => setFilter('flagged')}
                        className={`px-4 py-2 rounded-md text-sm font-medium transition-all ${filter === 'flagged' ? 'bg-red-50 text-red-600 shadow-sm' : 'text-gray-500 hover:bg-gray-50'}`}
                    >
                        Signalés ({comments.filter(c => c.is_flagged).length})
                    </button>
                </div>
            </div>

            <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                {loading ? (
                    <div className="p-8 text-center text-gray-400">Chargement...</div>
                ) : filteredComments.length === 0 ? (
                    <div className="p-12 text-center text-gray-500">Aucun commentaire à afficher.</div>
                ) : (
                    <div className="divide-y divide-gray-100">
                        {filteredComments.map((comment) => (
                            <div key={comment.id} className={`p-6 hover:bg-gray-50 transition-colors ${comment.is_flagged ? 'bg-red-50/30' : ''}`}>
                                <div className="flex justify-between items-start gap-4">
                                    <div className="flex-1">
                                        <div className="flex items-center gap-2 mb-2">
                                            <span className="font-bold text-[#053F5C]">@{comment.author}</span>
                                            <span className="text-xs text-gray-400">• {new Date(comment.posted_at).toLocaleDateString()}</span>
                                            {comment.is_flagged && (
                                                <span className="flex items-center gap-1 text-xs font-bold text-red-600 bg-red-100 px-2 py-0.5 rounded-full">
                                                    <Flag size={10} /> SIGNALÉ
                                                </span>
                                            )}
                                        </div>
                                        <p className="text-gray-800 text-sm mb-3 bg-white p-3 rounded border border-gray-100 inline-block w-full">
                                            "{comment.content}"
                                        </p>
                                        <div className="text-xs text-[#429EBD] font-medium flex items-center gap-1">
                                            Sur l'astuce : <span className="underline cursor-pointer hover:text-[#053F5C]">{comment.astuce_title}</span>
                                        </div>
                                    </div>

                                    <div className="flex flex-col gap-2">
                                        <button 
                                            onClick={() => handleDelete(comment.id)}
                                            className="p-2 text-red-500 hover:bg-red-100 rounded-lg transition-colors"
                                            title="Supprimer"
                                        >
                                            <Trash2 size={18} />
                                        </button>
                                        {comment.is_flagged && (
                                            <button 
                                                onClick={() => handleApprove(comment.id)}
                                                className="p-2 text-green-500 hover:bg-green-100 rounded-lg transition-colors"
                                                title="Approuver / Retirer signalement"
                                            >
                                                <Check size={18} />
                                            </button>
                                        )}
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>
                )}
            </div>
        </Layout>
    );
};