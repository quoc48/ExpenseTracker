import { ChevronRightIcon, StarIcon } from "lucide-react";
import React from "react";
import { Card, CardContent } from "@/components/ui/card";

export const FeaturedItemsSection = (): JSX.Element => {
  return (
    <Card className="w-full bg-white rounded-lg">
      <CardContent className="p-[17px]">
        <div className="flex w-full items-center justify-between mb-[32px]">
          <div className="flex items-center gap-2">
            <div className="inline-flex items-center justify-center p-2 bg-[#2c2c2c] rounded-[32px] border border-solid">
              <StarIcon className="w-5 h-5 text-white" />
            </div>
            <div className="[font-family:'SF_Pro_Text-Regular',Helvetica] font-normal text-[#303030] text-base tracking-[-0.17px] leading-[normal] whitespace-nowrap">
              Thực phẩm
            </div>
          </div>
          <div className="inline-flex items-center justify-center gap-0.5 cursor-pointer">
            <div className="[font-family:'SF_Pro_Text-Regular',Helvetica] font-normal text-[#303030] text-base tracking-[-0.17px] leading-[normal] whitespace-nowrap">
              Chi tiết
            </div>
            <ChevronRightIcon className="w-5 h-5 text-[#303030]" />
          </div>
        </div>
        <div className="text-[#1e1e1e] [font-family:'SF_Pro_Text-Semibold',Helvetica] font-normal text-[32px] tracking-[-0.17px] leading-[normal] whitespace-nowrap">
          5,857,231 đ
        </div>
      </CardContent>
    </Card>
  );
};
