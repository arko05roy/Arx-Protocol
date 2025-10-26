"use client"
import { ArrowRight, FileText } from 'lucide-react';
import { useRouter } from 'next/navigation';

export default function Hero() {
    const router = useRouter()
    return (
    <section
      id="vision"
      className="min-h-[100vh] bg-transparent bg-cover bg-center bg-no-repeat  items-center justify-center px-6 pt-32 pb-16"
      style={{ backgroundImage: "url('/Arx.jpg')" }}
    >
        <div className="mt-50">
          <p className="text-lg md:text-xl leading-relaxed max-w-5xl mx-auto text-center">
            ARX, is the first blockchain for ReFi that allows you to Participate, Own, and Earn through Proof backed carbon credits, tokenized  incentives, and onchain prediction markets and an open DeSCI dataset.
          </p>
        </div>
      <div className="max-w-6xl mx-auto w-full">
        <div className="flex justify-center">
          <div className="pt-8 flex flex-col sm:flex-row gap-4 justify-center items-center">
            <button 
            onClick={() => router.push('/dashboard')}
            className="px-8 py-4 bg-gaia-black text-gaia-yellow border-2 border-gaia-black hover:bg-[#606B16] hover:text-white transition-all flex items-center gap-2 font-medium text-lg group">
              Launch App
              <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
            </button>
            <button onClick={() => router.push('/whitepaper')}
            className="px-8 py-4 bg-transparent text-gaia-black border-2 border-gaia-black hover:bg-[#606B16] hover:text-white transition-all flex items-center gap-2 font-medium text-lg">
              <FileText className="w-5 h-5" />
              Read Whitepaper
            </button>
          </div>
        </div>

  
      </div>
    </section>
  );
}
