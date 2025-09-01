import { ChevronRightIcon } from "lucide-react";
import React from "react";
import { Card, CardContent } from "@/components/ui/card";

export const DailyStatsSection = (): JSX.Element => {
  return (
    <Card className="w-full bg-white rounded-lg">
      <CardContent className="p-[19px]">
        <div className="flex w-full items-start justify-between mb-[19px]">
          <div className="[font-family:'SF_Pro_Text-Regular',Helvetica] font-normal text-[#303030] text-base tracking-[-0.17px] leading-[normal] whitespace-nowrap">
            Hôm nay
          </div>

          <div className="inline-flex items-center justify-center gap-0.5">
            <div className="[font-family:'SF_Pro_Text-Regular',Helvetica] font-normal text-[#303030] text-base tracking-[-0.17px] leading-[normal] whitespace-nowrap">
              Hôm qua
            </div>

            <ChevronRightIcon className="w-5 h-5" />
          </div>
        </div>

        <div className="text-[#1e1e1e] [font-family:'SF_Pro_Text-Semibold',Helvetica] font-normal text-[32px] tracking-[-0.17px] leading-[normal] whitespace-nowrap">
          2,344,000 đ
        </div>
      </CardContent>
    </Card>
  );
};
