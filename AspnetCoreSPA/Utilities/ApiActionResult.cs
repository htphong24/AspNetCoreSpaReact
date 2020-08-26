﻿using System;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Text;
using System.Xml;
using System.Xml.Serialization;
using Common.Utilities;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using Newtonsoft.Json.Serialization;

namespace AspnetCoreSPATemplate.Utilities
{
    /// <summary>
    /// Serializes data into XML or JSON depending on the requested format as specified in the HTTP request <c>Content-Type</c> or <c>Accept</c> header
    /// </summary>
    /// <remarks>
    /// See <a href="http://james.newtonking.com/archive/2008/10/16/asp-net-mvc-and-json-net">here</a> for details.
    /// </remarks>
    public class ApiActionResult : ActionResult
    {
        private HttpRequest ContextRequest { get; set; }

        public Encoding ContentEncoding { get; set; }

        public string ContentType { get; set; }

        public object Data { get; set; }

        public JsonSerializerSettings JsonSerializerSettings { get; set; }

        public Newtonsoft.Json.Formatting JsonFormatting { get; set; }

        public const string XML_CONTENT_TYPE = "application/xml";
        public const string JSON_CONTENT_TYPE = "application/json";

        /// <summary>
        /// Basic constructor
        /// </summary>
        public ApiActionResult(HttpRequest contextRequest)
        {
            ContextRequest = contextRequest;

            JsonSerializerSettings = new JsonSerializerSettings
            {
                NullValueHandling = NullValueHandling.Ignore,
                ContractResolver = new CustomDateTimeFormatResolver(),
                DateTimeZoneHandling = DateTimeZoneHandling.Local
            };

            JsonFormatting = Newtonsoft.Json.Formatting.None;
            ContentEncoding = Encoding.UTF8;

            var dataType = ContextRequest.ContentType;

            if (string.IsNullOrWhiteSpace(dataType))
                dataType = ContextRequest.Headers["Accept"];

            if (string.IsNullOrWhiteSpace(dataType))
            {
                ContentType = JSON_CONTENT_TYPE;
            }
            else
            {
                dataType = dataType.ToLower();
                if (dataType.ToLower().Contains("application/json"))
                    ContentType = JSON_CONTENT_TYPE;
                else if (dataType.ToLower().Contains("application/xml"))
                    ContentType = XML_CONTENT_TYPE;
                else if (dataType.ToLower().Contains("multipart/form-data")
                         && !string.IsNullOrEmpty(ContextRequest.Headers["Accept"])
                         && ContextRequest.Headers["Accept"] == XML_CONTENT_TYPE)
                    ContentType = XML_CONTENT_TYPE;
                else
                    ContentType = JSON_CONTENT_TYPE;
            }
        }

        /// <summary>
        /// Constructor specifying the data to serialize
        /// </summary>
        /// <remarks>
        /// If <c>data</c> is an <see cref="Exception"/>, the exception will be encapsulated in <see cref="ApiError"/>.
        /// </remarks>
        public ApiActionResult(HttpRequest contextRequest, object data)
            : this(contextRequest)
        {
            if (data is Exception exception)
                Data = new ApiError(exception);
            else
                Data = data;
        }

        /// <summary>
        /// Write our JSON
        /// </summary>
        /// <param name="context"></param>
        public override void ExecuteResult(ActionContext context)
        {
            if (context == null)
                throw new ArgumentNullException(nameof(context));

            var response = context.HttpContext.Response;
            response.ContentType = this.ContentType;

            // StatusCodes:
            // - Status200OK
            // - Status201Created
            // - Status204NoContent
            // - Status400BadRequest
            // - Status404NotFound
            // - Status401Unauthorized
            // - Status500InternalServerError

            if (Data == null)
            {
                // NO Content
                response.StatusCode = StatusCodes.Status204NoContent;
            }
            else
            {
                response.StatusCode = Data is ApiError ? StatusCodes.Status500InternalServerError : StatusCodes.Status200OK;

                using var sw = new StreamWriter(response.Body);

                if (ContentType == XML_CONTENT_TYPE)
                {
                    using var writer = new XmlTextWriter(sw)
                    {
                        Formatting = System.Xml.Formatting.Indented
                    };

                    var serializer = new XmlSerializer(Data.GetType());
                    serializer.Serialize(writer, Data);
                }
                else
                {
                    using var writer = new JsonTextWriter(sw)
                    {
                        Formatting = JsonFormatting
                    };

                    var serializer = JsonSerializer.Create(JsonSerializerSettings);
                    serializer.Serialize(writer, Data);
                }

                // No need to use writer.Flush() since it is enclosed by "using"
            }
        }

        /// <summary>
        /// Custom JSON datetime serializer for date only properties with no timestamp
        /// </summary>
        /// <remarks>
        /// <para>
        /// The default format for <see cref="DateTime"/> is <c>2009-02-15T00:00:00Z</c>. For date only property, we do not want
        /// to serialize the time portion.
        /// </para>
        /// <para>
        /// This formatter serializes dates to <c>2009-02-15</c> if the property name ends to "Date".
        /// </para>
        /// See http://stackoverflow.com/questions/22858993/override-json-net-property-serialization-formatting.
        /// See http://www.newtonsoft.com/json/help/html/DatesInJSON.htm
        /// </remarks>
        public class CustomDateTimeFormatResolver : DefaultContractResolver
        {
            protected override JsonProperty CreateProperty(MemberInfo member, MemberSerialization memberSerialization)
            {
                var property = base.CreateProperty(member, memberSerialization);

                // skip if the property is not a DateTime
                if (property.PropertyType != typeof(DateTime) && property.PropertyType != typeof(DateTime?) &&
                    property.PropertyType != typeof(DateTimeOffset) && property.PropertyType != typeof(DateTimeOffset?))
                    return property;

                if (property.Converter != null && property.Converter.GetType() == typeof(CustomDateTimeFormatConverter))
                    return property;

                var converter = new IsoDateTimeConverter();

                if (member.Name.EndsWith("Date"))
                    converter.DateTimeFormat = "yyyy-MM-dd";
                else
                    // For serialization ... this converts to UTC
                    // It gets ignored for deserialization
                    converter.DateTimeStyles = DateTimeStyles.AdjustToUniversal;
                property.Converter = converter;

                return property;
            }
        }
    }
}