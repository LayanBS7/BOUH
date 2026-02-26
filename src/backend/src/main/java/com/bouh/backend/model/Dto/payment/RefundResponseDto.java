package com.bouh.backend.model.Dto.payment;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class RefundResponseDto {
    private String refundId;
    private String status;
    private Long amount;
    private String currency;
}
