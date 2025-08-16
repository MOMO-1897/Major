// src/admin/admin.controller.ts
import { Controller, Get, Post, Render, Body, Res, Session, Query, Param } from '@nestjs/common';
import { Response } from 'express';
import { AdminService } from './admin.service';

@Controller('admin')
export class AdminController {

    constructor(private readonly adminService: AdminService) {}

    @Get('dashboard')
    async getDashboard(@Session() session: Record<string, any>, @Res() res: Response) {
        // If the user object does not exist in the session, redirect to the login page.
        if (!session.user) {
            return res.redirect('/admin/login');
        }

        try {
            // Fetch all dynamic data from the service
            const dashboardData = await this.adminService.getDashboardData();

            // If authenticated, render the dashboard view with the data
            return res.render('index', {
                title: 'Admin Dashboard',
                message: `Welcome, ${session.user.username}!`,
                user: session.user,
                counts: dashboardData.counts,
                reports: dashboardData.reports
            });
        } catch (error) {
            console.error('Failed to load dashboard data:', error);
            // Handle the error gracefully, maybe show a message to the user
            return res.render('index', {
                title: 'Admin Dashboard',
                message: `Welcome, ${session.user.username}!`,
                user: session.user,
                counts: { farmers: 0, specialists: 0, pending: 0 },
                reports: [],
                errorMessage: 'Failed to load dashboard data.'
            });
        }
    }

    @Get('farmers')
    @Render('farmers')
    async getFarmersPage() {
        try {
            // Fetch all farmer profiles with their associated user data
            const farmers = await this.adminService.findAllFarmers();
            // Pass the fetched farmers data to the EJS view
            return {
                title: 'Farmers List',
                farmers: farmers
            };
        } catch (error) {
            console.error('Error fetching farmers for EJS page:', error);
            // Render the page with an error and an empty farmers array
            return {
                title: 'Farmers List',
                farmers: [],
                errorMessage: 'Failed to load farmers.'
            };
        }
    }

    @Get('login')
    @Render('login')
    getLoginPage(@Query('error') error: string) {
        const errorMessage = error ? 'Invalid credentials. Please try again.' : null;
        return { title: 'Admin Login', errorMessage };
    }

    @Post('login')
    async handleLogin(
        @Body() body: any,
        @Session() session: Record<string, any>,
        @Res() res: Response
    ) {
        const { username, password } = body;
        const user = await this.adminService.validateAdminLogin(username, password);

        if (!user) {
            console.error('Login failed: Invalid credentials or not an admin.');
            return res.redirect('/admin/login?error=1');
        }
        
        session.user = {
            id: user._id,
            username: user.username,
            role: (user.role as any).name,
        };

        return res.redirect('/admin/dashboard');
    }

    @Get('pending')
    @Render('pending')
    async getPendingPage() { // Make this an async function
        // Fetch the pending specialists from the service
        const pendingSpecialists = await this.adminService.findPendingSpecialists();
        // Pass the data to the EJS template
        return {
            title: 'Pending Applications',
            pendingSpecialists: pendingSpecialists,
        };
    }

    @Post('verify-specialist/:id')
    async verifySpecialist(
        @Res() res: Response,
        // Changed from @Body('id') to @Param('id') to correctly get the ID from the URL.
        @Param('id') specialistId: string
    ) {
        try {
            await this.adminService.verifySpecialist(specialistId);
            return res.redirect('/admin/pending'); // Redirect back to the pending page
        } catch (error) {
            console.error('Error verifying specialist:', error);
            return res.status(500).send('Failed to verify specialist.');
        }
    }

    @Get('specialists')
    @Render('specialists')
    async getSpecialistsPage() {
        try {
            // Fetch all specialist profiles with their associated user data
            const specialists = await this.adminService.findAllSpecialists();
            // Pass the fetched specialists data to the EJS view
            console.log(specialists)
            return {
                title: 'Specialists List',
                specialists: specialists
            };
        } catch (error) {
            console.error('Error fetching specialists for EJS page:', error);
            // Render the page with an error and an empty specialists array
            return {
                title: 'Specialists List',
                specialists: [],
                errorMessage: 'Failed to load specialists.'
            };
        }
    }

    /**
     * New POST route to handle the deletion of a report.
     * It takes the report ID from the URL parameter.
     */
    @Post('delete-report/:id')
    async deleteReport(@Param('id') id: string, @Res() res: Response) {
        try {
            const deletedReport = await this.adminService.deleteReport(id);
            if (!deletedReport) {
                // If no report was found to delete, you might want to handle this specifically
                console.warn(`Attempted to delete a report that does not exist: ${id}`);
            }
            // Redirect back to the dashboard after successful deletion
            res.redirect('/admin/dashboard');
        } catch (error) {
            console.error(`Error deleting report with ID ${id}:`, error);
            // Redirect with an error message or render an error page
            res.status(500).send('Failed to delete report.');
        }
    }

    @Get('logout')
    handleLogout(@Session() session: Record<string, any>, @Res() res: Response) {
      session.destroy((err) => {
        if (err) {
          console.error('Error destroying session:', err);
          return res.status(500).send('Could not log out.');
        }
        res.clearCookie('connect.sid'); // Clear the session cookie
        res.redirect('/admin/login');
      });
    }
}
