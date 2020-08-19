﻿using System.ComponentModel.DataAnnotations;
// ReSharper disable CheckNamespace

namespace Services
{
    public class ContactModel
    {
        public int Id { get; set; }

        [Required]
        public string FirstName { get; set; }

        [Required]
        public string LastName { get; set; }

        public string Company { get; }

        public string Address { get; }

        public string City { get; }

        public string State { get; }

        public string Post { get; }

        [Required]
        public string Phone1 { get; set; }

        public string Phone2 { get; }

        [Required]
        [EmailAddress]
        public string Email { get; set; }

        public string Web { get; }
    }
}