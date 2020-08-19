﻿using AutoMapper;
using Microsoft.EntityFrameworkCore;
using SqlServerDataAccess.EF;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
// ReSharper disable CheckNamespace

namespace Services
{
    public class SqlServerContactRepository : RepositoryBase, IContactRepository, IContactModificationRepository
    {
        public SqlServerContactRepository(
            ContactsMgmtContext db,
            ContactsMgmtIdentityContext idDb,
            IMapper mapper)
            : base(db, idDb, mapper)
        {
        }

        public async Task<List<ContactModel>> ListAsync(ContactListRequest rq)
        {
            // Create query
            IQueryable<Contact> query = Db.Contacts
                                          .Skip(rq.SkipCount)
                                          .Take(rq.TakeCount);
            // Retrieve data
            List<Contact> contacts = await query.ToListAsync();
            // Map to model
            List<ContactModel> dtoList = Mapper.Map<List<ContactModel>>(contacts);

            return dtoList;
        }

        public async Task<ContactModel> GetAsync(ContactGetRequest rq)
        {
            // Create query
            IQueryable<Contact> query = Db.Contacts
                                          .Where(c => c.ContactId == rq.Id);
            // Retrieve data
            Contact contact = await query.FirstOrDefaultAsync();
            // Map to model
            ContactModel dto = Mapper.Map<ContactModel>(contact);
            // Detach contact
            Db.Entry(contact).State = EntityState.Detached;

            return dto;
        }

        public async Task<int> ListRecordCountAsync()
        {
            // Create query
            IQueryable<Contact> query = Db.Contacts;
            // Retrieve data
            int recordCount = await query.CountAsync();

            return recordCount;
        }

        public async Task<List<ContactModel>> SearchAsync(ContactSearchRequest rq)
        {
            // Create query
            IQueryable<Contact> query = Db.Contacts
                                          .Where(c => c.FirstName.Contains(rq.Query)
                                                   || c.LastName.Contains(rq.Query)
                                                   || c.Email.Contains(rq.Query)
                                                   || c.Phone1.Contains(rq.Query))
                                          .Skip(rq.SkipCount)
                                          .Take(rq.TakeCount);
            // Retrieve data
            List<Contact> contacts = await query.ToListAsync();
            // Map to model
            List<ContactModel> dtoList = Mapper.Map<List<ContactModel>>(contacts);

            return dtoList;
        }

        public async Task<int> SearchRecordCountAsync(ContactSearchRequest rq)
        {
            // Create query
            IQueryable<Contact> query = Db.Contacts
                                          .Where(c => c.FirstName.Contains(rq.Query)
                                                   || c.LastName.Contains(rq.Query)
                                                   || c.Email.Contains(rq.Query)
                                                   || c.Phone1.Contains(rq.Query));
            // Retrieve data
            int recordCount = await query.CountAsync();

            return recordCount;
        }

        public async Task CreateAsync(ContactCreateRequest rq)
        {
            ContactModel dto = rq.Contact;
            if (IsEmailInUse(dto.Email))
                throw new Exception("Email is in use.");

            Contact result = Mapper.Map<Contact>(dto);
            await Db.Contacts.AddAsync(result);
            // Save data
            await Db.SaveChangesAsync();
        }

        public async Task UpdateAsync(ContactUpdateRequest rq)
        {
            ContactModel dto = rq.Contact;
            // Retrieve old email
            string oldEmail = Db.Contacts
                                .Where(c => c.ContactId == dto.Id)
                                .Select(c => c.Email)
                                .FirstOrDefault();
            // Check whether the new email is the same as the old one or it is being used by others
            if (IsEmailInUse(dto.Email, oldEmail))
                throw new Exception("Email is in use.");

            // It's not in use, then update the contact
            Contact result = Mapper.Map<Contact>(dto);
            Db.Contacts.Update(result);
            // Save data
            await Db.SaveChangesAsync();
        }

        public async Task DeleteAsync(ContactDeleteRequest rq)
        {
            ContactModel dto = rq.Contact;
            Contact result = Mapper.Map<Contact>(dto);
            Db.Remove(result);
            // Save data
            await Db.SaveChangesAsync();
        }

        public async Task ReloadAsync(ContactReloadRequest rq)
        {
            await Db.Database.ExecuteSqlCommandAsync("ReloadContacts");
        }

        public bool IsEmailInUse(string email, string oldEmail = null)
        {
            // If new email is the same as old email
            if (oldEmail != null && oldEmail == email)
                // Then it's OK
                return false;

            // If not, check whether it is being used by other contacts
            // Create Query
            var query = Db.Contacts.Where(c => c.Email == email);
            // Retrieve data, do not use async method here
            bool isInUse = query.Any();

            return isInUse;
        }
    }
}