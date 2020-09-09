﻿using System;
using System.Threading.Tasks;
using BotDetect.Web;

// ReSharper disable CheckNamespace

namespace Services
{
    public class AuthenticationLoginGetService : ServiceBase<AuthenticationLoginGetRequest, AuthenticationLoginGetResponse>
    {
        private readonly IAuthenticationRepository _authRepo;

        public AuthenticationLoginGetService(ServiceContext context, IAuthenticationRepository authRepo)
            : base(context)
        {
            _authRepo = authRepo;
        }

        /// <summary>
        /// Lists the results of a client search.
        /// </summary>
        /// <param name="rq">Request</param>
        /// <returns>Response</returns>
        protected override async Task<AuthenticationLoginGetResponse> DoRunAsync(AuthenticationLoginGetRequest rq)
        {
            return new AuthenticationLoginGetResponse();
        }
    }
}