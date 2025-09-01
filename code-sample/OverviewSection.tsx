import { ChevronRightIcon, StarIcon } from "lucide-react";
import React from "react";
import { Card, CardContent } from "@/components/ui/card";

export const OverviewSection = (): JSX.Element => {
  const expenseItems = [
    {
      name: "Bánh canh cá lóc",
      amount: "65,000 đ",
      date: "Today",
    },
    {
      name: "Ăn sáng",
      amount: "23,000 đ",
      date: "Today",
    },
    {
      name: "Nạp 3G",
      amount: "8,000 đ",
      date: "Today",
    },
    {
      name: "Đi chợ",
      amount: "132,000 đ",
      date: "Yesterday",
    },
    {
      name: "Netflix",
      amount: "53,000 đ",
      date: "12/8/2025",
    },
    {
      name: "Cà phê trên cty",
      amount: "33,000 đ",
      date: "12/8/2025",
    },
  ];

  return (
    <section className="flex flex-col w-full items-start gap-3 relative">
      <header className="flex items-center justify-between relative self-stretch w-full flex-[0_0_auto]">
        <h2 className="relative w-fit mt-[-1.00px] [font-family:'SF_Pro_Text-Bold',Helvetica] font-bold text-black text-xl tracking-[-0.17px] leading-[normal] whitespace-nowrap">
          Chi tiêu gần đây
        </h2>

        <button className="inline-flex items-center justify-center gap-0.5 relative flex-[0_0_auto] cursor-pointer">
          <span className="relative w-fit mt-[-0.50px] [font-family:'SF_Pro_Text-Regular',Helvetica] font-normal text-[#303030] text-base tracking-[-0.17px] leading-[normal] whitespace-nowrap">
            Tất cả
          </span>
          <ChevronRightIcon className="relative w-5 h-5" />
        </button>
      </header>

      {expenseItems.map((item, index) => (
        <Card
          key={index}
          className="flex flex-col items-start gap-2.5 p-3 relative self-stretch w-full flex-[0_0_auto] bg-neutral-100 rounded-lg overflow-hidden border-0"
        >
          <CardContent className="flex items-center gap-2 relative self-stretch w-full flex-[0_0_auto] p-0">
            <div className="inline-flex items-center justify-center p-2 relative flex-[0_0_auto] bg-[#2c2c2c] rounded-[32px] overflow-hidden border border-solid">
              <StarIcon className="relative w-5 h-5 text-white" />
            </div>

            <div className="flex flex-col items-start gap-1 relative flex-1 grow">
              <div className="flex items-center gap-3 relative self-stretch w-full flex-[0_0_auto]">
                <div className="relative flex-1 mt-[-1.00px] [font-family:'SF_Pro_Text-Regular',Helvetica] font-normal text-[#1e1e1e] text-base tracking-[-0.17px] leading-[normal]">
                  {item.name}
                </div>

                <div className="relative w-fit mt-[-1.00px] [font-family:'SF_Pro_Text-Semibold',Helvetica] font-normal text-[#1e1e1e] text-base tracking-[-0.17px] leading-[normal] whitespace-nowrap">
                  {item.amount}
                </div>
              </div>

              <div className="relative self-stretch [font-family:'SF_Pro_Text-Regular',Helvetica] font-normal text-[#5a5a5a] text-xs tracking-[-0.17px] leading-[normal]">
                {item.date}
              </div>
            </div>
          </CardContent>
        </Card>
      ))}
    </section>
  );
};
