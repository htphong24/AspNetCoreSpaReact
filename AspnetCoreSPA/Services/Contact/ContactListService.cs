﻿using AspnetCoreSPATemplate.Models;
using AspnetCoreSPATemplate.Services.Common;
using AutoMapper;
using SqlServerDataAccess;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace AspnetCoreSPATemplate.Services
{
    public class ContactListService : ServiceBase<ContactListRequest, ContactListResponse>
    {
        private readonly IContactRepository _contactRepo;

        public ContactListService(ServiceContext context, IContactRepository contactRepo)
            : base(context)
        {
            _contactRepo = contactRepo;
        }

        /// <summary> 
        /// Lists the results of a client search.
        /// </summary> 
        /// <param name="rq">Request</param> 
        /// <returns>Response</returns>
        protected override async Task<ContactListResponse> DoRunAsync(ContactListRequest rq)
        {
            ContactListResponse rs = new ContactListResponse();
            rs.Results = await _contactRepo.ListAsync(rq);
            rs.RecordCount = await _contactRepo.ListRecordCountAsync();
            rs.PageCount = (rs.RecordCount + rq.RowsPerPage - 1) / rq.RowsPerPage;
            rs.PageNumber = rq.PageNumber;
            return rs;
        }
    }
}