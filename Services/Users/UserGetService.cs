﻿using System.Threading.Tasks;
// ReSharper disable CheckNamespace

namespace Services
{
    public class UserGetService : ServiceBase<UserGetRequest, UserGetResponse>
    {
        private readonly IUserRepository _userRepo;
        private readonly ServiceContext _context;

        public UserGetService(ServiceContext context, IUserRepository userRepo)
            : base(context)
        {
            _userRepo = userRepo;
            _context = context;
        }

        /// <summary>
        /// Lists the results of a client search.
        /// </summary>
        /// <param name="rq">Request</param>
        /// <returns>Response</returns>
        protected override async Task<UserGetResponse> DoRunAsync(UserGetRequest rq)
        {
            var rs = new UserGetResponse
            {
                User = await _userRepo.GetAsync(rq)
            };

            return rs;
        }
    }
}