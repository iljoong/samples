using System;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading;

public static async Task<HttpResponseMessage> Run(HttpRequestMessage req, TraceWriter log)
{
    dynamic data = await req.Content.ReadAsAsync<object>();
    var message =  $"Azure alert: '{data.context.name}' at {data.context.timestamp}; {data.context.details}";

    // slack channel
    var baseaddr = "https://hooks.slack.com";
    var alertch = "https://hooks.slack.com/services/T0JuQbs.....RYX";

    // teams channel
    //var baseaddr = "https://outlook.office.com";
    //var alertch = "https://outlook.office.com/webhook/../IncomingWebhook/..d0";

    try
    {
        using (var client = new HttpClient())
        {
            client.BaseAddress = new Uri(baseaddr);
            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

            var response = await client.PostAsJsonAsync(alertch, new { text = message });
            log.Info($"return: {response.StatusCode}");

            return req.CreateResponse(HttpStatusCode.OK, new { status = response.StatusCode});
        }  
    }
    catch (Exception ex)
    {
        return req.CreateResponse(HttpStatusCode.InternalServerError, new { status = ex.Message  });
    }
}