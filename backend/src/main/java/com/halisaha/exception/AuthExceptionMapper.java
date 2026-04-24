package com.halisaha.exception;

import com.halisaha.dto.ApiResponse;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.ext.ExceptionMapper;
import jakarta.ws.rs.ext.Provider;

@Provider
public class AuthExceptionMapper implements ExceptionMapper<AuthException> {

    @Override
    public Response toResponse(AuthException exception) {
        return Response.status(exception.getStatusCode())
                .entity(ApiResponse.hata(exception.getMessage()))
                .build();
    }
}
