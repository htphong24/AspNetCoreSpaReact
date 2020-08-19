﻿using System;

namespace AspnetCoreSPATemplate.Utilities
{
    /// <summary>
    /// Encapsulates errors to return to the client
    /// </summary>
    public class ApiError
    {
        public bool IsError { get; set; }
        public string ErrorCode { get; set; }
        public string ErrorMessage { get; set; }

        /// <summary>
        /// Basic constructor
        /// </summary>
        public ApiError()
        {
            IsError = true;
        }

        /// <summary>
        /// Constructor initializing properties with details from an exception
        /// </summary>
        /// <param name="ex">Exception to send to client via JSON</param>
        public ApiError(Exception ex)
        {
            IsError = true;
            ErrorMessage = ex.Message;
            //if (ex is ServiceException)
            //{
            //    this.ErrorCode = ((ServiceException)ex).ErrorCode;
            //}
        }
    }
}