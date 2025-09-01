import { ChevronRightIcon } from "lucide-react";
import React from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";

export const BudgetSummarySection = (): JSX.Element => {
  return (
    <Card className="w-full bg-[#2c2c2c] rounded-lg border-none">
      <CardContent className="p-4 space-y-4">
        <div className="flex items-center justify-between">
          <div className="[font-family:'SF_Pro_Text-Regular',Helvetica] font-normal text-[#f2f2f2] text-base tracking-[-0.17px] leading-[normal]">
            Tháng 8
          </div>

          <Button
            variant="ghost"
            className="h-auto p-0 text-[#f2f2f2] hover:bg-transparent"
          >
            <div className="flex items-center gap-0.5">
              <span className="[font-family:'SF_Pro_Text-Regular',Helvetica] font-normal text-base tracking-[-0.17px] leading-[normal]">
                Tháng trước
              </span>
              <ChevronRightIcon className="w-5 h-5" />
            </div>
          </Button>
        </div>

        <div className="text-neutral-100 [font-family:'SF_Pro_Text-Semibold',Helvetica] font-normal text-[32px] tracking-[-0.17px] leading-[normal]">
          16,500,000 đ
        </div>

        <div className="flex items-center justify-between">
          <div className="[font-family:'SF_Pro_Text-Regular',Helvetica] font-normal text-[#f2f2f2] text-base tracking-[-0.17px] leading-[normal]">
            So với ngân sách
          </div>

          <div className="[font-family:'SF_Pro_Text-Regular',Helvetica] font-normal text-[#f2f2f2] text-base tracking-[-0.17px] leading-[normal]">
            60%
          </div>
        </div>

        <div className="relative w-full h-4 bg-[#d9d9d9] rounded-[100px] overflow-hidden">
          <div className="w-[66.26%] h-full rounded-[64px] shadow-[0px_6px_24px_#1262fb52] bg-[linear-gradient(225deg,rgba(47,81,255,1)_0%,rgba(14,51,243,1)_100%)]" />
        </div>
      </CardContent>
    </Card>
  );
};
