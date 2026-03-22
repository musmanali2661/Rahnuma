import React from 'react';

export default function Button({ children, onClick, variant = 'primary', disabled, className = '' }) {
  const base = 'px-4 py-2 rounded-lg font-medium text-sm transition focus:outline-none focus:ring-2 focus:ring-offset-2';
  const variants = {
    primary: 'bg-green-700 text-white hover:bg-green-800 focus:ring-green-500 disabled:opacity-50',
    secondary: 'bg-white text-gray-700 border border-gray-300 hover:bg-gray-50 focus:ring-gray-400 disabled:opacity-50',
    danger: 'bg-red-600 text-white hover:bg-red-700 focus:ring-red-500 disabled:opacity-50',
  };

  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={`${base} ${variants[variant]} ${className}`}
    >
      {children}
    </button>
  );
}
