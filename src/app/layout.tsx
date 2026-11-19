import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'Overseas Infrastructure | Finance Management',
  description: 'Business finance management and cash flow control',
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="en"><body>{children}</body></html>;
}