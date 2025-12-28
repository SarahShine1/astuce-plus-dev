import React from 'react';

interface StatCardProps {
  title: string;
  value: string | number;
  icon: React.ElementType;
  trend?: string;
  color?: string;
}

export const StatCard: React.FC<StatCardProps> = ({ title, value, icon: Icon, trend, color = "text-[#053F5C]" }) => {
  return (
    <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 hover:shadow-md transition-shadow">
      <div className="flex items-start justify-between">
        <div>
          <p className="text-sm font-medium text-gray-500 mb-1">{title}</p>
          <h3 className="text-2xl font-bold text-gray-900">{value}</h3>
          {trend && (
            <p className="text-xs font-medium text-green-600 mt-2">
              {trend}
            </p>
          )}
        </div>
        <div className={`p-3 rounded-lg bg-gray-50 ${color}`}>
          <Icon size={24} />
        </div>
      </div>
    </div>
  );
};