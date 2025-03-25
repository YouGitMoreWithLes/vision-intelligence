namespace SalesForcePlugin;

public class CustomerLeadsService : ICustomerLeadsService
{
    public CustomerLeadsService()
    {}

    public void CreateCustomerLead()
    {
        Console.WriteLine("CustomerLead created");
    }

    public void UpdateCustomerLead()
    {
        Console.WriteLine("CustomerLead updated");
    }

    public void DeleteCustomerLead()
    {
        Console.WriteLine("CustomerLead deleted");
    }

    public void RetrieveCustomerLeads()
    {
        Console.WriteLine("CustomerLeads retrieved");
    }
}
